#!/bin/bash

# Efficient FTP sync script that only uploads truly changed files

echo "🔍 Checking for file changes..."

# Create checksums directory if it doesn't exist
mkdir -p .deploy-cache

# Generate checksums for current dist files
find dist -type f -exec md5 {} \; > .deploy-cache/current-checksums.txt 2>/dev/null

# Extract current and previous asset filenames for comparison
CURRENT_CSS=$(find dist/_astro -name "index.*.css" 2>/dev/null | head -1 | sed 's/dist\///')
CURRENT_JS=$(find dist/_astro -name "*.js" 2>/dev/null | head -1 | sed 's/dist\///')

# Check for hashed asset changes (Astro cache-busting)
FORCE_SYNC=false
if [ -f .deploy-cache/previous-assets.txt ]; then
    PREVIOUS_CSS=$(grep "css:" .deploy-cache/previous-assets.txt 2>/dev/null | cut -d':' -f2-)
    PREVIOUS_JS=$(grep "js:" .deploy-cache/previous-assets.txt 2>/dev/null | cut -d':' -f2-)
    
    if [ "$CURRENT_CSS" != "$PREVIOUS_CSS" ] || [ "$CURRENT_JS" != "$PREVIOUS_JS" ]; then
        echo "🔄 Detected new hashed assets (CSS/JS cache-busting files)"
        echo "  Previous CSS: $PREVIOUS_CSS"
        echo "  Current CSS:  $CURRENT_CSS"
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
    open ftp://STIMSONS%40chimesapp.com:Kilburn.12345@ftp.chimesapp.com
    lcd dist
    mirror -R --delete --verbose --parallel=3 --ignore-time . /
"

# Save current checksums as previous for next run
cp .deploy-cache/current-checksums.txt .deploy-cache/previous-checksums.txt

# Save current asset filenames for next run
echo "css:$CURRENT_CSS" > .deploy-cache/previous-assets.txt
echo "js:$CURRENT_JS" >> .deploy-cache/previous-assets.txt

echo "✅ Sync complete!"
