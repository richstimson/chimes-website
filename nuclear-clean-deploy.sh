#!/bin/bash
# Complete site wipe and clean deployment via FTP
# This is the nuclear option - removes everything and starts fresh

echo "🧹 Complete Site Wipe & Clean Deployment"
echo "========================================"
echo ""
echo "⚠️  WARNING: This will DELETE ALL FILES on your website!"
echo "⚠️  Only proceed if you're ready to replace everything with clean files."
echo ""
read -p "Are you sure you want to WIPE and REBUILD your entire site? (type 'YES' to confirm): " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
    echo "❌ Operation cancelled"
    exit 1
fi

echo ""
echo "FTP Credentials:"
read -p "cPanel Username: " FTP_USER
read -s -p "cPanel Password: " FTP_PASS
echo ""
echo ""

# Test FTP connection first
echo "🔌 Testing FTP connection..."
FTP_HOST="ftp.chimesapp.com"

lftp -c "
set ftp:ssl-allow no
set ftp:ssl-protect-data no
set cmd:fail-exit yes
open -u $FTP_USER,$FTP_PASS $FTP_HOST
pwd
quit
" 2>/dev/null

if [ $? -ne 0 ]; then
    echo "❌ FTP connection failed"
    exit 1
fi

echo "✅ FTP connection successful"
echo ""

# Step 1: Complete wipe of public_html/chimesapp
echo "🗑️  Step 1: Wiping infected website files..."
lftp -c "
set ftp:ssl-allow no
set ftp:ssl-protect-data no
open -u $FTP_USER,$FTP_PASS $FTP_HOST
cd public_html/chimesapp
rm -rf *
rm -rf .*
quit
"

if [ $? -eq 0 ]; then
    echo "✅ All infected files deleted"
else
    echo "❌ Wipe failed - check FTP permissions"
    exit 1
fi

echo ""

# Step 2: Upload clean site
echo "📤 Step 2: Uploading clean Astro site..."
lftp -c "
set ftp:ssl-allow no
set ftp:ssl-protect-data no
open -u $FTP_USER,$FTP_PASS $FTP_HOST
lcd /Users/stimson/src/chimes-website/dist/
cd public_html/chimesapp/
mirror -R --delete --verbose .
quit
"

if [ $? -eq 0 ]; then
    echo "✅ Clean site uploaded successfully!"
    echo ""
    echo "🎉 DEPLOYMENT COMPLETE!"
    echo "====================="
    echo ""
    echo "✅ All infected files removed"
    echo "✅ Clean Astro site deployed"
    echo "✅ Website should be working now"
    echo ""
    echo "🔒 Security Next Steps:"
    echo "1. Test your site: https://chimesapp.com"
    echo "2. Contact Bluehost to request site reactivation"
    echo "3. Change ALL passwords (hosting, FTP, email)"
    echo "4. Monitor for any unusual activity"
    echo ""
    echo "Your site should be clean and secure now!"
else
    echo "❌ Upload failed"
    echo "Check FTP permissions and try again"
    exit 1
fi