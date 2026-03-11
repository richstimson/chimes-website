#!/bin/bash
# Deployment script for chimesapp.com
# This script uploads your clean Astro site to your hosting provider

# Configuration - UPDATE THESE VALUES
FTP_HOST="your-ftp-server.com"
FTP_USER="your-ftp-username"
FTP_PASS="your-ftp-password"
REMOTE_PATH="/public_html/chimesapp/"
LOCAL_DIST="/Users/stimson/src/chimes-website/dist/"

echo "Starting deployment of clean site files..."

# Method 1: Using rsync over FTP (if available)
# rsync -avz --delete "$LOCAL_DIST" "$FTP_USER@$FTP_HOST:$REMOTE_PATH"

# Method 2: Using lftp (more reliable for FTP)
lftp -c "
set ftp:ssl-allow no;
open -u $FTP_USER,$FTP_PASS $FTP_HOST;
lcd $LOCAL_DIST;
cd $REMOTE_PATH;
mirror -R --delete --verbose .;
quit
"

echo "Deployment completed!"
echo ""
echo "Post-deployment checklist:"
echo "1. Test your site: https://chimesapp.com"
echo "2. Run another security scan"
echo "3. Monitor for any unusual activity"
echo "4. Set up automated backups"