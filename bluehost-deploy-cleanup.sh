#!/bin/bash
# Bluehost-specific deployment script for cleanup
# This script works with Bluehost's SSH configuration

echo "Bluehost SSH Connection Test and Cleanup Deployment"
echo "=================================================="

# Test common Bluehost connection methods
DOMAIN="chimesapp.com"
USERNAME="stimsons"  # Update this with your actual cPanel username

echo "Testing SSH connections to Bluehost..."

# Test Method 1: Direct domain
echo "Testing: ssh $USERNAME@$DOMAIN"
ssh -o ConnectTimeout=10 -o BatchMode=yes $USERNAME@$DOMAIN "echo 'SSH connection successful via domain'" 2>/dev/null
if [ $? -eq 0 ]; then
    SSH_HOST="$USERNAME@$DOMAIN"
    echo "✓ SSH works via domain: $SSH_HOST"
else
    echo "✗ SSH via domain failed"
fi

# Test Method 2: Try to find server hostname
echo ""
echo "If domain SSH failed, you'll need to find your Bluehost server hostname."
echo "Check your cPanel for something like: server123.bluehost.com"
echo ""

# Function to deploy cleanup
deploy_cleanup() {
    local ssh_host=$1
    echo "Deploying cleanup script to: $ssh_host"
    
    # Upload cleanup script
    scp cleanup-hosting.sh "$ssh_host:/home1/stimsons/"
    
    if [ $? -eq 0 ]; then
        echo "✓ Cleanup script uploaded successfully"
        
        # Execute cleanup
        echo "Running cleanup script..."
        ssh "$ssh_host" "cd /home1/stimsons && chmod +x cleanup-hosting.sh && ./cleanup-hosting.sh"
        
        if [ $? -eq 0 ]; then
            echo "✓ Cleanup completed successfully!"
        else
            echo "✗ Cleanup execution failed"
        fi
    else
        echo "✗ Upload failed"
    fi
}

# If SSH connection was successful, deploy
if [ -n "$SSH_HOST" ]; then
    read -p "SSH connection successful! Deploy cleanup now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        deploy_cleanup "$SSH_HOST"
    fi
else
    echo ""
    echo "SSH connection failed. Try these alternatives:"
    echo ""
    echo "1. Enable SSH in Bluehost cPanel:"
    echo "   - Log into cPanel"
    echo "   - Find 'SSH Access' in Advanced section"
    echo "   - Enable SSH access"
    echo ""
    echo "2. Use manual upload method:"
    echo "   ./bluehost-manual-cleanup.sh"
    echo ""
    echo "3. Try with server hostname:"
    echo "   ssh $USERNAME@server###.bluehost.com"
    echo "   (Replace ### with your actual server number from cPanel)"
fi