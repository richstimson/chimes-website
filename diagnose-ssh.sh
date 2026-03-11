#!/bin/bash
# Bluehost SSH Diagnostic Script
# This script helps identify why SSH isn't working

echo "🔍 Bluehost SSH Diagnostic Report"
echo "=================================="
echo ""

# Server details
DOMAIN="chimesapp.com"
USERNAME="stimsons"
SERVER_IP="66.235.200.146"
SERVER_HOST="host77.ipowerweb.com"

echo "📋 Server Information:"
echo "Domain: $DOMAIN"
echo "Server IP: $SERVER_IP"
echo "Server Hostname: $SERVER_HOST"
echo "Username: $USERNAME"
echo ""

echo "🔌 Connection Tests:"
echo "==================="

# Test 1: Basic connectivity
echo "1. Testing basic connectivity to server..."
ping -c 2 $SERVER_HOST >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "   ✅ Server is reachable"
else
    echo "   ❌ Server unreachable"
fi

# Test 2: Check common SSH ports
echo ""
echo "2. Testing SSH ports..."
for port in 22 2222 2200 22000; do
    echo -n "   Port $port: "
    timeout 5 bash -c "</dev/tcp/$SERVER_HOST/$port" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ OPEN"
        SSH_PORT=$port
    else
        echo "❌ Closed/Filtered"
    fi
done

echo ""
echo "🔑 SSH Key Diagnostic:"
echo "====================="

# Check if SSH key exists locally
if [ -f ~/.ssh/id_rsa.pub ]; then
    echo "✅ Local SSH public key exists: ~/.ssh/id_rsa.pub"
    echo "Key fingerprint:"
    ssh-keygen -lf ~/.ssh/id_rsa.pub
else
    echo "❌ No local SSH public key found"
    echo "You may need to download the private key from cPanel"
fi

echo ""
echo "🐛 Common Bluehost SSH Issues:"
echo "=============================="
echo ""
echo "Issue 1: SSH not enabled on this plan"
echo "  - Some Bluehost plans don't include SSH"
echo "  - Check your hosting plan features"
echo ""
echo "Issue 2: SSH requires specific hostname"
echo "  - Try: ssh $USERNAME@$DOMAIN"
echo "  - Try: ssh $USERNAME@$SERVER_HOST"
echo "  - Try: ssh $USERNAME@secure.$DOMAIN"
echo ""
echo "Issue 3: SSH key not properly configured"
echo "  - Download private key from cPanel"
echo "  - Save as ~/.ssh/bluehost_rsa"
echo "  - Set permissions: chmod 600 ~/.ssh/bluehost_rsa"
echo "  - Use: ssh -i ~/.ssh/bluehost_rsa $USERNAME@$DOMAIN"
echo ""
echo "Issue 4: Firewall blocking SSH"
echo "  - Bluehost may block SSH from certain locations"
echo "  - Try from different network/VPN"
echo ""

echo "💡 Next Steps:"
echo "============="
echo ""
if [ ! -z "$SSH_PORT" ]; then
    echo "✅ SSH port $SSH_PORT is open - try connecting with:"
    echo "   ssh -p $SSH_PORT $USERNAME@$SERVER_HOST"
else
    echo "❌ No SSH ports are open. This suggests:"
    echo "   1. SSH is not enabled on your Bluehost plan"
    echo "   2. SSH is blocked by firewall"
    echo "   3. SSH requires a different hostname"
    echo ""
    echo "🔄 Alternative Solutions:"
    echo "   1. Use cPanel Terminal (if available)"
    echo "   2. Use FTP + manual execution: ./bluehost-manual-cleanup.sh"
    echo "   3. Contact Bluehost support to enable SSH"
    echo "   4. Download private key and try with -i flag"
fi

echo ""
echo "📞 If SSH still doesn't work:"
echo "   Contact Bluehost Support: 1-855-746-6194"
echo "   Tell them: 'I need SSH access enabled for malware cleanup'"