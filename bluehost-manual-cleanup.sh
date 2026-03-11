#!/bin/bash
# Manual cleanup deployment for Bluehost (when SSH is not available)
# This uploads the script via FTP and provides manual execution steps

echo "Bluehost Manual Cleanup Deployment"
echo "=================================="

# Bluehost FTP settings
FTP_HOST="ftp.chimesapp.com"
FTP_USER="stimsons"  # Update with your actual cPanel username
echo "FTP Host: $FTP_HOST"
echo "FTP User: $FTP_USER"
echo ""

read -s -p "Enter your cPanel password: " FTP_PASS
echo ""

echo "Uploading cleanup script to Bluehost via FTP..."

# Create upload script for lftp
cat > /tmp/bluehost_upload.lftp << EOF
set ftp:ssl-allow no
set ftp:ssl-protect-data no
open -u $FTP_USER,$FTP_PASS $FTP_HOST
lcd /Users/stimson/src/chimes-website/
cd /home1/stimsons/
put cleanup-hosting.sh
quit
EOF

# Upload using lftp
lftp -f /tmp/bluehost_upload.lftp

if [ $? -eq 0 ]; then
    echo "✓ Cleanup script uploaded successfully!"
    
    # Clean up temp file
    rm /tmp/bluehost_upload.lftp
    
    echo ""
    echo "NEXT STEPS - Execute cleanup manually:"
    echo "======================================"
    echo ""
    echo "Method 1: cPanel Terminal (Recommended)"
    echo "---------------------------------------"
    echo "1. Log into your Bluehost cPanel"
    echo "2. Find 'Terminal' in Advanced section"
    echo "3. Click Terminal to open command line"
    echo "4. Run these commands:"
    echo "   cd /home1/stimsons"
    echo "   chmod +x cleanup-hosting.sh"
    echo "   ./cleanup-hosting.sh"
    echo ""
    echo "Method 2: cPanel File Manager + Cron Job"
    echo "----------------------------------------"
    echo "1. Log into cPanel"
    echo "2. Go to File Manager"
    echo "3. Navigate to /home1/stimsons/"
    echo "4. Right-click cleanup-hosting.sh"
    echo "5. Select 'Change Permissions' → Set to 755"
    echo "6. Go to 'Cron Jobs' in cPanel"
    echo "7. Create a one-time job to run:"
    echo "   /home1/stimsons/cleanup-hosting.sh"
    echo ""
    echo "Method 3: Contact Bluehost Support"
    echo "---------------------------------"
    echo "1. Call Bluehost support"
    echo "2. Explain you need to run a malware cleanup script"
    echo "3. Ask them to execute: /home1/stimsons/cleanup-hosting.sh"
    echo ""
    echo "The cleanup script is now on your server and ready to run!"
    
else
    echo "✗ FTP upload failed"
    echo ""
    echo "Troubleshooting:"
    echo "1. Check your cPanel username and password"
    echo "2. Try FTP host: ftp.yourdomain.com"
    echo "3. Ensure FTP access is enabled in cPanel"
    echo "4. Contact Bluehost if issues persist"
    
    # Clean up temp file
    rm -f /tmp/bluehost_upload.lftp
fi