#!/bin/bash
# Enhanced Bluehost FTP upload with multiple hostname attempts

echo "🔧 Bluehost FTP Upload - Enhanced Version"
echo "========================================"
echo ""

# Get credentials
echo "FTP Credentials needed:"
read -p "cPanel Username: " FTP_USER
read -s -p "cPanel Password: " FTP_PASS
echo ""
echo ""

# Common Bluehost FTP hostnames
FTP_HOSTS=(
    "ftp.chimesapp.com"
    "chimesapp.com" 
    "host77.ipowerweb.com"
    "ftp.bluehost.com"
    "66.235.200.146"
)

echo "Testing FTP connections..."
echo ""

for FTP_HOST in "${FTP_HOSTS[@]}"; do
    echo "Trying FTP host: $FTP_HOST"
    
    # Create test connection
    lftp -c "
    set ftp:ssl-allow no
    set ftp:ssl-protect-data no
    set cmd:fail-exit yes
    open -u $FTP_USER,$FTP_PASS $FTP_HOST
    pwd
    quit
    " 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ FTP connection successful to: $FTP_HOST"
        echo ""
        echo "Uploading cleanup script..."
        
        # Upload the cleanup script
        lftp -c "
        set ftp:ssl-allow no
        set ftp:ssl-protect-data no
        open -u $FTP_USER,$FTP_PASS $FTP_HOST
        lcd /Users/stimson/src/chimes-website/
        cd /home1/$FTP_USER/
        put cleanup-hosting.sh
        quit
        "
        
        if [ $? -eq 0 ]; then
            echo "✅ Cleanup script uploaded successfully!"
            echo ""
            echo "🎯 NEXT STEPS - Execute the cleanup:"
            echo "================================="
            echo ""
            echo "Method 1: cPanel Terminal (Recommended)"
            echo "---------------------------------------"
            echo "1. Log into your Bluehost cPanel"
            echo "2. Look for 'Terminal' in the Advanced section"
            echo "3. Click Terminal to open command line"
            echo "4. Run these commands:"
            echo "   cd /home1/$FTP_USER"
            echo "   chmod +x cleanup-hosting.sh"
            echo "   ./cleanup-hosting.sh"
            echo ""
            echo "Method 2: cPanel File Manager"
            echo "----------------------------"
            echo "1. Log into cPanel"
            echo "2. Go to File Manager"
            echo "3. Navigate to /home1/$FTP_USER/"
            echo "4. Find cleanup-hosting.sh"
            echo "5. Right-click → Change Permissions → Set to 755"
            echo "6. Right-click → Edit → Add this line at the top:"
            echo "   #!/bin/bash"
            echo "7. Create a Cron Job to run the script once"
            echo ""
            echo "The cleanup script is now on your server!"
            echo "It will remove all 40 infected files found in the scan."
            exit 0
        else
            echo "❌ Upload failed to $FTP_HOST"
        fi
    else
        echo "❌ Connection failed to $FTP_HOST"
    fi
    echo ""
done

echo "❌ All FTP connections failed"
echo ""
echo "🔧 Manual Upload Instructions:"
echo "============================="
echo ""
echo "1. Use cPanel File Manager:"
echo "   - Log into Bluehost cPanel"
echo "   - Open File Manager"
echo "   - Navigate to /home1/$FTP_USER/"
echo "   - Click Upload"
echo "   - Upload: /Users/stimson/src/chimes-website/cleanup-hosting.sh"
echo ""
echo "2. Set permissions and run:"
echo "   - Right-click cleanup-hosting.sh"
echo "   - Change Permissions → 755"
echo "   - Use Terminal (if available) or Cron Job to execute"
echo ""
echo "📞 If issues persist:"
echo "   Contact Bluehost Support: 1-855-746-6194"
echo "   Tell them: 'Need to upload and run malware cleanup script'"