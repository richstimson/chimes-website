#!/bin/bash

# Efficient FTP sync script that only uploads truly changed files

source "$(cd "$(dirname "$0")" && pwd)/load-ftp-secrets.sh"

echo "🔍 Checking for file changes..."

# Create checksums directory if it doesn't exist
mkdir -p .deploy-cache

# Generate checksums for current dist files
find dist -type f -exec md5 {} \; > .deploy-cache/current-checksums.txt 2>/dev/null

# Extract current hashed asset filenames for comparison
CURRENT_ASTRO_ASSETS=$(find dist/_astro -maxdepth 1 -type f 2>/dev/null | sort | sed 's#^dist/##')

# Check for hashed asset changes (Astro cache-busting)
FORCE_SYNC=false
if [ -f .deploy-cache/previous-assets.txt ]; then
    PREVIOUS_ASTRO_ASSETS=$(cat .deploy-cache/previous-assets.txt 2>/dev/null)
    
    if [ "$CURRENT_ASTRO_ASSETS" != "$PREVIOUS_ASTRO_ASSETS" ]; then
        echo "🔄 Detected changes in hashed Astro assets"
        echo "  Previous assets:"
        if [ -n "$PREVIOUS_ASTRO_ASSETS" ]; then
            echo "$PREVIOUS_ASTRO_ASSETS" | sed 's/^/    - /'
        else
            echo "    - none"
        fi
        echo "  Current assets:"
        if [ -n "$CURRENT_ASTRO_ASSETS" ]; then
            echo "$CURRENT_ASTRO_ASSETS" | sed 's/^/    - /'
        else
            echo "    - none"
        fi
        FORCE_SYNC=true
    fi
else
    echo "📦 First run - will sync all files"
    FORCE_SYNC=true
fi

# Compare with previous checksums if they exist
if [ -f .deploy-cache/previous-checksums.txt ] && [ "$FORCE_SYNC" = false ]; then
    # Find files that have actually changed
    CHANGED_FILES=$(comm -13 <(sort .deploy-cache/previous-checksums.txt) <(sort .deploy-cache/current-checksums.txt) | cut -d' ' -f4- | cut -d'=' -f2-)
    
    if [ -z "$CHANGED_FILES" ]; then
        echo "⚡ No file content changes detected, skipping sync..."
        exit 0
    else
        echo "📦 Found $(echo "$CHANGED_FILES" | wc -l | tr -d ' ') changed files:"
        echo "$CHANGED_FILES" | sed 's/^/  - /'
    fi
else
    if [ "$FORCE_SYNC" = true ]; then
        echo "� Forcing sync due to asset changes or first run"
    else
        echo "�📦 First run - will sync all files"
    fi
fi

# Use lftp with more conservative settings
echo "🚀 Syncing to server..."
lftp -c "
    set ssl:verify-certificate no
    set ftp:list-options -a
    open ftp://$CHIMES_FTP_HOST
    user $CHIMES_FTP_USER $CHIMES_FTP_PASSWORD
    lcd dist
    mirror -R --delete --verbose --parallel=3 --ignore-time \
        --exclude-glob _astro \
        --exclude-glob _astro/* \
        --exclude-glob _astro/** \
        --exclude-glob .well-known \
        --exclude-glob .ftpquota \
        . /
    lcd _astro
    mirror -R --verbose --parallel=3 --ignore-time \
        . /_astro
"

# Save current checksums as previous for next run
cp .deploy-cache/current-checksums.txt .deploy-cache/previous-checksums.txt

# Save current asset filenames for next run
printf '%s\n' "$CURRENT_ASTRO_ASSETS" > .deploy-cache/previous-assets.txt

echo "✅ Sync complete!"
