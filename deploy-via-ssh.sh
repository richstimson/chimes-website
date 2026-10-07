#!/bin/bash

# OBSOLETE: superseded by `npm run smart-deploy` (sync-smart.sh), which runs the
# checks in deploy-guards.sh. This script skips those checks, so it could publish
# an out-of-date build or one without /privacy. It refuses to run.
echo "❌ $(basename "$0") is obsolete and disabled. Use: npm run smart-deploy" >&2
exit 1
# Alternative deployment using scp (if you have SSH access)
# Replace with your actual server details

SERVER_HOST="your-server.com"
SERVER_USER="your-username"
REMOTE_PATH="/home1/stimsons/public_html/chimesapp/"
LOCAL_DIST="/Users/stimson/src/chimes-website/dist/"

echo "Deploying via SCP/SSH..."

# Create backup of current site (optional)
# ssh $SERVER_USER@$SERVER_HOST "tar -czf /tmp/chimesapp-backup-$(date +%Y%m%d).tar.gz $REMOTE_PATH"

# Upload clean files
scp -r "$LOCAL_DIST"* "$SERVER_USER@$SERVER_HOST:$REMOTE_PATH"

echo "Deployment via SCP completed!"