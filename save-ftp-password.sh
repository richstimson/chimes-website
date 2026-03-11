#!/bin/bash

set -euo pipefail

FTP_USER="${CHIMES_FTP_USER:-STIMSONS@chimesapp.com}"
KEYCHAIN_SERVICE="${CHIMES_FTP_KEYCHAIN_SERVICE:-chimes-ftp-password}"

read -s -p "FTP Password for $FTP_USER: " FTP_PASS
echo ""

if [ -z "$FTP_PASS" ]; then
  echo "❌ Password cannot be empty"
  exit 1
fi

security add-generic-password -a "$FTP_USER" -s "$KEYCHAIN_SERVICE" -w "$FTP_PASS" -U >/dev/null
echo "✅ Saved to macOS Keychain (service: $KEYCHAIN_SERVICE, account: $FTP_USER)"