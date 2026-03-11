#!/bin/bash

set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/load-ftp-secrets.sh"
echo "$CHIMES_FTP_PASSWORD"