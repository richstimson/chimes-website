#!/bin/bash

# Efficient SFTP sync script that only uploads truly changed files
#
# DRY_RUN=1 ./sync-smart.sh shows what the mirror would upload and delete
# without changing the server or the deploy cache.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$SCRIPT_DIR/deploy-guards.sh"
require_deploy_guards || exit 1

source "$SCRIPT_DIR/deploy-target.sh" || exit 1

DRY_RUN_FLAG=""
if [ "${DRY_RUN:-}" = "1" ]; then
    DRY_RUN_FLAG="--dry-run"
    echo "🧪 Dry run: nothing will be uploaded or deleted"
fi

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

# A dry run always shows the full mirror plan
if [ -n "$DRY_RUN_FLAG" ]; then
    FORCE_SYNC=true
fi

# Files added, changed or removed since the last deploy. Lines look like
# "MD5 (dist/path) = hash"; a removed file appears only in the previous
# list, so compare both ways or deleting a page never syncs.
CHANGED_FILES=""
if [ -f .deploy-cache/previous-checksums.txt ]; then
    CHANGED_FILES=$(comm -3 <(sort .deploy-cache/previous-checksums.txt) <(sort .deploy-cache/current-checksums.txt) \
        | sed -E 's/^[[:space:]]*MD5 \((.*)\) = .*/\1/' | sort -u)
fi

if [ -f .deploy-cache/previous-checksums.txt ] && [ "$FORCE_SYNC" = false ]; then
    if [ -z "$CHANGED_FILES" ]; then
        echo "⚡ No file content changes detected, skipping sync..."
        exit 0
    else
        echo "📦 Found $(echo "$CHANGED_FILES" | wc -l | tr -d ' ') added, changed or removed files:"
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
    $CHIMES_LFTP_OPEN
    lcd dist
    mirror -R --delete --verbose --parallel=3 --ignore-time $DRY_RUN_FLAG \
        --exclude-glob _astro \
        --exclude-glob _astro/* \
        --exclude-glob _astro/** \
        --exclude-glob .well-known/ \
        --exclude-glob .ftpquota \
        . $CHIMES_REMOTE_ROOT
    lcd _astro
    mirror -R --verbose --parallel=3 --ignore-time $DRY_RUN_FLAG \
        . $CHIMES_REMOTE_ROOT/_astro
"
LFTP_STATUS=$?

if [ "$LFTP_STATUS" -ne 0 ]; then
    echo "❌ lftp failed (exit $LFTP_STATUS); deploy cache left unchanged"
    exit "$LFTP_STATUS"
fi

# --ignore-time makes the mirror compare by size only, so a page whose only
# change is a same-length asset hash (_slug_.AAAA.css -> _slug_.BBBB.css) is
# skipped and the server keeps the old page (2026-11-01: 16 pages stale after a
# theme change). Upload every file whose checksum changed, whatever its size.
PUT_CMDS=""
while IFS= read -r f; do
    [ -f "$f" ] || continue                  # removed: the mirror deleted it
    case "$f" in dist/_astro/*) continue ;; esac  # hashed names: mirror sends them
    rel="${f#dist/}"
    PUT_CMDS="$PUT_CMDS put -O \"$CHIMES_REMOTE_ROOT/$(dirname "$rel")\" \"$f\";"
    [ -n "$DRY_RUN_FLAG" ] && echo "  would force-upload $rel"
done <<< "$CHANGED_FILES"

if [ -n "$PUT_CMDS" ] && [ -z "$DRY_RUN_FLAG" ]; then
    echo "📤 Force-uploading changed files the size-only mirror may skip..."
    lftp -c "$CHIMES_LFTP_OPEN; $PUT_CMDS"
    PUT_STATUS=$?
    if [ "$PUT_STATUS" -ne 0 ]; then
        echo "❌ lftp put failed (exit $PUT_STATUS); deploy cache left unchanged"
        exit "$PUT_STATUS"
    fi
fi

if [ -n "$DRY_RUN_FLAG" ]; then
    echo "✅ Dry run complete; deploy cache left unchanged"
    exit 0
fi

# Save current checksums as previous for next run
cp .deploy-cache/current-checksums.txt .deploy-cache/previous-checksums.txt

# Save current asset filenames for next run
printf '%s\n' "$CURRENT_ASTRO_ASSETS" > .deploy-cache/previous-assets.txt

echo "✅ Sync complete!"
