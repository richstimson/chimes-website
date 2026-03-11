# Bluehost SSH Setup Guide

## Method 1: Enable SSH via cPanel (Recommended)

### Step 1: Enable SSH Access
1. **Log into your Bluehost cPanel**
2. **Find "SSH Access"** in the Advanced section
3. **Click "Manage SSH Keys"**
4. **Enable SSH access** if it's not already enabled
5. **Generate a new SSH key pair** (if needed)

### Step 2: Find Your SSH Details
- **Hostname**: Usually `yourdomain.com` or `server###.bluehost.com`
- **Username**: Your cPanel username (usually your domain without .com)
- **Port**: 22 (default)

### Step 3: Test SSH Connection
```bash
# Test SSH connection from your Mac
ssh your-username@yourdomain.com

# Or try the server hostname format
ssh your-username@server###.bluehost.com
```

## Method 2: If SSH is Not Available

### Option A: cPanel File Manager (Manual)
1. **Upload cleanup script via cPanel File Manager**
2. **Set permissions to 755**
3. **Run via cPanel Terminal** (if available)

### Option B: FTP Upload + cPanel Terminal
1. **Use FTP to upload cleanup script**
2. **Access cPanel Terminal**
3. **Execute the script manually**

---

## Bluehost-Specific Settings

### Common Bluehost SSH Hostnames:
- `yourdomain.com`
- `server###.bluehost.com` (check your cPanel for exact server)
- `box###.bluehost.com`

### SSH Port: 
- **Port 22** (standard)

### Username Format:
- Usually your **cPanel username**
- Sometimes `username@yourdomain.com`

---

## Quick Setup Commands

Once you have SSH details, I'll customize the deployment script with your specific Bluehost settings.

**What we need:**
1. Your domain name
2. Your cPanel username
3. Confirmation that SSH is enabled

Let me know these details and I'll update the scripts immediately!