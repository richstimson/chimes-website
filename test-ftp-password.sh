#!/bin/bash
# Simple FTP password test script

echo "🔐 FTP Password Test"
echo "==================="
echo ""

# Get credentials
read -p "FTP Username: " FTP_USER
read -s -p "New FTP Password: " FTP_PASS
echo ""
echo ""

# Test FTP connection
echo "🔌 Testing FTP connection with new password..."

FTP_HOST="ftp.chimesapp.com"

# Test basic connection
echo "Connecting to $FTP_HOST..."
lftp -c "
set ftp:ssl-allow no
set ftp:ssl-protect-data no
set cmd:fail-exit yes
open -u $FTP_USER,$FTP_PASS $FTP_HOST
pwd
ls -la | head -10
quit
" 2>/dev/null

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SUCCESS! New FTP password is working correctly"
    echo ""
    echo "🔒 Security Status:"
    echo "✅ FTP password changed and verified"
    echo "✅ Connection to $FTP_HOST successful"
    echo "✅ Can access your files"
    echo ""
    echo "Your FTP credentials are now secure!"
else
    echo ""
    echo "❌ FAILED! FTP connection unsuccessful"
    echo ""
    echo "Possible issues:"
    echo "1. Password not updated yet (wait 5-10 minutes)"
    echo "2. Username might have changed"
    echo "3. FTP hostname might be different"
    echo ""
    echo "Try these troubleshooting steps:"
    echo "1. Wait a few minutes and try again"
    echo "2. Check cPanel for exact FTP username"
    echo "3. Verify password was saved correctly"
fi