#!/bin/bash
# Test various Bluehost SSH connection methods with the private key

KEY_FILE="~/.ssh/bluehost_rsa"
USERNAME="stimsons"
DOMAIN="chimesapp.com"

echo "🔑 Testing SSH with Downloaded Private Key"
echo "=========================================="
echo ""

# Test various hostname patterns Bluehost might use
HOSTNAMES=(
    "chimesapp.com"
    "host77.ipowerweb.com" 
    "box2081.bluehost.com"
    "server.chimesapp.com"
    "ssh.bluehost.com"
    "gator4077.hostgator.com"
)

PORTS=(22 2222 2200 22000)

echo "Testing hostname and port combinations..."
echo ""

for hostname in "${HOSTNAMES[@]}"; do
    for port in "${PORTS[@]}"; do
        echo -n "Testing: ssh -i $KEY_FILE -p $port $USERNAME@$hostname ... "
        
        # Test connection with timeout
        timeout 8 ssh -i ~/.ssh/bluehost_rsa -p $port -o ConnectTimeout=5 -o BatchMode=yes $USERNAME@$hostname "echo 'SUCCESS'" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "✅ SUCCESS!"
            echo ""
            echo "🎉 SSH Connection Found!"
            echo "Use this command: ssh -i ~/.ssh/bluehost_rsa -p $port $USERNAME@$hostname"
            echo ""
            
            # Deploy cleanup automatically
            echo "Deploying cleanup script..."
            scp -i ~/.ssh/bluehost_rsa -P $port /Users/stimson/src/chimes-website/cleanup-hosting.sh $USERNAME@$hostname:/home1/stimsons/
            if [ $? -eq 0 ]; then
                echo "✅ Script uploaded! Running cleanup..."
                ssh -i ~/.ssh/bluehost_rsa -p $port $USERNAME@$hostname "cd /home1/stimsons && chmod +x cleanup-hosting.sh && ./cleanup-hosting.sh"
                echo "🎉 Cleanup completed!"
                exit 0
            fi
        else
            echo "❌ Failed"
        fi
    done
done

echo ""
echo "❌ No working SSH connection found"
echo ""
echo "This suggests one of:"
echo "1. SSH is not enabled for external connections on your Bluehost plan"
echo "2. SSH requires VPN or specific IP whitelist"
echo "3. SSH uses a hostname not in our test list"
echo ""
echo "💡 Next steps:"
echo "1. Check cPanel for 'Terminal' option (internal SSH)"
echo "2. Contact Bluehost support to confirm SSH access"
echo "3. Use FTP upload method: ./bluehost-manual-cleanup.sh"