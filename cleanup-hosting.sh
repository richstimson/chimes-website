#!/bin/bash
# Cleanup script for chimesapp.com hosting
# This script removes all infected files and suspicious directories found in the scan

echo "Starting cleanup of infected files from chimesapp.com..."
echo "Scan found 40 infected files - removing all malicious content"

# Create backup directory for logs
mkdir -p /tmp/chimesapp-cleanup-$(date +%Y%m%d)
LOG_FILE="/tmp/chimesapp-cleanup-$(date +%Y%m%d)/cleanup.log"

echo "Cleanup started at $(date)" > $LOG_FILE

# Change to the website directory
cd /home1/stimsons/public_html/chimesapp/

# Remove infected directories entirely (these appear to be malicious)
echo "Removing suspicious directories..."
echo "Removing infected directories..." >> $LOG_FILE

if [ -d "vendor-getting-started-clean" ]; then
    echo "Removing vendor-getting-started-clean/" | tee -a $LOG_FILE
    rm -rf vendor-getting-started-clean/
fi

if [ -d "vendor-getting-started" ]; then
    echo "Removing vendor-getting-started/" | tee -a $LOG_FILE
    rm -rf vendor-getting-started/
fi

if [ -d "NewDGT" ]; then
    echo "Removing NewDGT/" | tee -a $LOG_FILE
    rm -rf NewDGT/
fi

if [ -d "Cr" ]; then
    echo "Removing Cr/" | tee -a $LOG_FILE
    rm -rf Cr/
fi

# Remove specific infected files mentioned in scan
echo "Removing specific infected files..."
echo "Removing specific infected files..." >> $LOG_FILE

# Remove the malicious PHP file in root
if [ -f "fffm.php" ]; then
    echo "Removing fffm.php" | tee -a $LOG_FILE
    rm -f fffm.php
fi

# Additional cleanup - remove common malware file patterns
echo "Scanning for additional malware patterns..."
echo "Additional malware scan..." >> $LOG_FILE

# Remove any config.php files that aren't legitimate
find . -name "config.php" -not -path "*/wp-*" -not -path "*/legitimate-app/*" -delete -print >> $LOG_FILE

# Remove common malware files
find . -name "infos.php" -delete -print >> $LOG_FILE
find . -name "anti*.php" -delete -print >> $LOG_FILE
find . -name "*uploader*.php" -delete -print >> $LOG_FILE

# Remove files with suspicious content patterns
echo "Scanning for files with malicious code patterns..."
find . -name "*.php" -exec grep -l "base64_decode\|eval\|gzinflate\|str_rot13\|\\$_POST\[.*eval" {} \; -delete -print >> $LOG_FILE

# Remove any remaining error_log files that might contain malicious code
find . -name "error_log" -delete -print >> $LOG_FILE

# Remove any remaining error_log files that might contain malicious code
find . -name "error_log" -delete -print >> $LOG_FILE

# Verify cleanup
echo ""
echo "Cleanup verification..."
echo "Cleanup verification at $(date)" >> $LOG_FILE

# Check if any suspicious directories remain
echo "Checking for remaining suspicious directories..."
if [ -d "vendor-getting-started-clean" ] || [ -d "vendor-getting-started" ] || [ -d "NewDGT" ] || [ -d "Cr" ]; then
    echo "WARNING: Some suspicious directories still exist!" | tee -a $LOG_FILE
else
    echo "✓ All suspicious directories removed" | tee -a $LOG_FILE
fi

# Check for remaining PHP files with suspicious names
SUSPICIOUS_FILES=$(find . -name "anti*.php" -o -name "infos.php" -o -name "*uploader*.php" -o -name "fffm.php" 2>/dev/null)
if [ -n "$SUSPICIOUS_FILES" ]; then
    echo "WARNING: Suspicious files still found:" | tee -a $LOG_FILE
    echo "$SUSPICIOUS_FILES" | tee -a $LOG_FILE
else
    echo "✓ No suspicious files found" | tee -a $LOG_FILE
fi

echo ""
echo "Cleanup completed at $(date)!" | tee -a $LOG_FILE
echo "Log file saved to: $LOG_FILE"
echo ""
echo "NEXT STEPS:"
echo "1. Upload your clean Astro site files"
echo "2. Change ALL passwords (hosting, FTP, admin)"
echo "3. Run another security scan"
echo "4. Contact hosting provider to request site reactivation"
echo ""
echo "Cleanup summary logged to: $LOG_FILE"