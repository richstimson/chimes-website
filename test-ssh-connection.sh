#!/bin/bash
# Bluehost SSH Connection Helper
# Run this after setting up SSH keys in cPanel

echo "Bluehost SSH Connection Test"
echo "============================"
echo ""

# Common Bluehost connection patterns
DOMAIN="chimesapp.com"
USERNAME="stimsons"  # Your cPanel username

echo "Testing SSH connections with different hostnames..."
echo ""

# Test 1: Domain directly
echo "1. Testing: ssh $USERNAME@$DOMAIN"
timeout 10 ssh -o ConnectTimeout=5 -o BatchMode=yes $USERNAME@$DOMAIN "echo 'Connection successful'" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "   ✅ SUCCESS: Use ssh $USERNAME@$DOMAIN"
    SSH_WORKING="$USERNAME@$DOMAIN"
else
    echo "   ❌ Failed"
fi

# Test 2: FTP hostname
echo ""
echo "2. Testing: ssh $USERNAME@ftp.$DOMAIN"
timeout 10 ssh -o ConnectTimeout=5 -o BatchMode=yes $USERNAME@ftp.$DOMAIN "echo 'Connection successful'" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "   ✅ SUCCESS: Use ssh $USERNAME@ftp.$DOMAIN"
    SSH_WORKING="$USERNAME@ftp.$DOMAIN"
else
    echo "   ❌ Failed"
fi

# Test 3: Try to find server hostname from DNS
echo ""
echo "3. Looking up server hostname..."
SERVER_IP=$(dig +short $DOMAIN | head -1)
if [ ! -z "$SERVER_IP" ]; then
    SERVER_HOSTNAME=$(dig +short -x $SERVER_IP | sed 's/\.$//')
    if [ ! -z "$SERVER_HOSTNAME" ]; then
        echo "   Found server: $SERVER_HOSTNAME"
        echo "   Testing: ssh $USERNAME@$SERVER_HOSTNAME"
        timeout 10 ssh -o ConnectTimeout=5 -o BatchMode=yes $USERNAME@$SERVER_HOSTNAME "echo 'Connection successful'" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "   ✅ SUCCESS: Use ssh $USERNAME@$SERVER_HOSTNAME"
            SSH_WORKING="$USERNAME@$SERVER_HOSTNAME"
        else
            echo "   ❌ Failed"
        fi
    fi
fi

echo ""
echo "============================"
if [ ! -z "$SSH_WORKING" ]; then
    echo "🎉 SSH IS WORKING!"
    echo "Connection string: $SSH_WORKING"
    echo ""
    echo "Ready to deploy cleanup? (y/n)"
    read -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Deploying cleanup script..."
        scp cleanup-hosting.sh "$SSH_WORKING:/home1/stimsons/"
        if [ $? -eq 0 ]; then
            echo "✅ Script uploaded! Running cleanup..."
            ssh "$SSH_WORKING" "cd /home1/stimsons && chmod +x cleanup-hosting.sh && ./cleanup-hosting.sh"
        else
            echo "❌ Upload failed"
        fi
    fi
else
    echo "❌ SSH not working yet"
    echo ""
    echo "Next steps:"
    echo "1. Make sure you clicked 'Authorize' on your SSH key in cPanel"
    echo "2. Wait 5-10 minutes for SSH to activate"
    echo "3. Try manual connection: ssh $USERNAME@$DOMAIN"
    echo "4. Check cPanel for your specific server hostname"
    echo ""
    echo "Alternative: Use manual cleanup method"
    echo "./bluehost-manual-cleanup.sh"
fi