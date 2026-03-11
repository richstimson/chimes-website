#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$SCRIPT_DIR/.env.local" ]; then
  set -a
  . "$SCRIPT_DIR/.env.local"
  set +a
fi

export CHIMES_FTP_HOST="${CHIMES_FTP_HOST:-ftp.chimesapp.com}"
export CHIMES_FTP_USER="${CHIMES_FTP_USER:-STIMSONS@chimesapp.com}"
export CHIMES_FTP_KEYCHAIN_SERVICE="${CHIMES_FTP_KEYCHAIN_SERVICE:-chimes-ftp-password}"

if [ -z "${CHIMES_FTP_PASSWORD:-}" ] && command -v security >/dev/null 2>&1; then
  CHIMES_FTP_PASSWORD=$(security find-generic-password -a "$CHIMES_FTP_USER" -s "$CHIMES_FTP_KEYCHAIN_SERVICE" -w 2>/dev/null || true)
  export CHIMES_FTP_PASSWORD
fi

if [ -z "${CHIMES_FTP_PASSWORD:-}" ]; then
  echo "❌ FTP password not found"
  echo "Set one of:"
  echo "  1) CHIMES_FTP_PASSWORD env var"
  echo "  2) .env.local with CHIMES_FTP_PASSWORD=..."
  echo "  3) macOS Keychain entry:"
  echo "     security add-generic-password -a '$CHIMES_FTP_USER' -s '$CHIMES_FTP_KEYCHAIN_SERVICE' -w '<password>' -U"
  return 1 2>/dev/null || exit 1
fi