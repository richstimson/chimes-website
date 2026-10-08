#!/bin/bash

# OBSOLETE: superseded by `npm run smart-deploy` (sync-smart.sh), which runs the
# checks in deploy-guards.sh. This script skips those checks, so it could publish
# an out-of-date build or one without /privacy. It refuses to run.
echo "❌ $(basename "$0") is obsolete and disabled. Use: npm run smart-deploy" >&2
exit 1

# Smart deployment script that only builds if source files have changed

# Check if dist directory exists and if source files are newer than dist
NEED_BUILD=false

if [ ! -d "dist" ]; then
    echo "📦 No dist directory found, building..."
    NEED_BUILD=true
elif find src -newer dist -print -quit | grep -q .; then
    echo "📦 Source files changed, rebuilding..."
    NEED_BUILD=true
elif find public -newer dist -print -quit | grep -q .; then
    echo "📦 Public files changed, rebuilding..."
    NEED_BUILD=true
elif [ "package.json" -nt "dist" ] || [ "astro.config.mjs" -nt "dist" ] || [ "tsconfig.json" -nt "dist" ]; then
    echo "📦 Config files changed, rebuilding..."
    NEED_BUILD=true
else
    echo "⚡ No changes detected, skipping build..."
fi

# Build if needed
if [ "$NEED_BUILD" = true ]; then
    npm run build
    if [ $? -ne 0 ]; then
        echo "❌ Build failed!"
        exit 1
    fi
fi

# Sync to server
echo "🚀 Syncing to server..."
npm run sync-ftp

echo "✅ Deployment complete!"
