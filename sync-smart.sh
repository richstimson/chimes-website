#!/bin/bash

# Efficient FTP sync script that only uploads truly changed files

echo "🔍 Checking for file changes..."

# Create checksums directory if it doesn't exist
mkdir -p .deploy-cache

# Generate checksums for current dist files
find dist -type f -exec md5 {} \; > .deploy-cache/current-checksums.txt 2>/dev/null

# Compare with previous checksums if they exist
if [ -f .deploy-cache/previous-checksums.txt ]; then
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
    echo "📦 First run - will sync all files"
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

echo "✅ Sync complete!"
