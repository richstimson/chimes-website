#!/bin/bash
# Deploy and run cleanup script on chimesapp.com server
# This script uploads the cleanup script and executes it remotely

# Server configuration - UPDATE THESE
SERVER_HOST="your-server.com"  # Replace with your actual server
SERVER_USER="stimsons"         # Your cPanel username
SERVER_PATH="/home1/stimsons/"

echo "Deploying cleanup script to chimesapp.com server..."

# Method 1: If you have SSH access
echo "Uploading cleanup script via SCP..."
scp cleanup-hosting.sh $SERVER_USER@$SERVER_HOST:$SERVER_PATH/

echo "Connecting to server and running cleanup..."
ssh $SERVER_USER@$SERVER_HOST "cd $SERVER_PATH && chmod +x cleanup-hosting.sh && ./cleanup-hosting.sh"

echo ""
echo "Cleanup deployment completed!"
echo "Check the output above for any errors or warnings."