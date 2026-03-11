#!/bin/bash
# Upload cleanup script via FTP and provide instructions for manual execution

# FTP Configuration - UPDATE THESE
FTP_HOST="ftp.yourdomain.com"  # Replace with your FTP server
FTP_USER="stimsons"            # Your FTP username  
FTP_PASS="your-ftp-password"   # Your FTP password

echo "Uploading cleanup script via FTP..."

# Upload the cleanup script using lftp
lftp -c "
set ftp:ssl-allow no;
open -u $FTP_USER,$FTP_PASS $FTP_HOST;
lcd /Users/stimson/src/chimes-website/;
cd /home1/stimsons/;
put cleanup-hosting.sh;
quit
"

echo ""
echo "✓ Cleanup script uploaded to your server!"
echo ""
echo "MANUAL STEPS TO COMPLETE:"
echo "1. Log into your hosting control panel (cPanel)"
echo "2. Go to File Manager"
echo "3. Navigate to /home1/stimsons/"
echo "4. Right-click cleanup-hosting.sh and select 'Change Permissions'"
echo "5. Set permissions to 755 (executable)"
echo "6. Open Terminal in cPanel or SSH"
echo "7. Run: cd /home1/stimsons && ./cleanup-hosting.sh"
echo ""
echo "OR if you have SSH access:"
echo "ssh stimsons@your-server.com"
echo "chmod +x cleanup-hosting.sh"
echo "./cleanup-hosting.sh"