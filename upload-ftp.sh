#!/bin/bash

set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/load-ftp-secrets.sh"

cd dist
find . -type f -exec curl -T {} "ftp://$CHIMES_FTP_HOST/{}" --user "$CHIMES_FTP_USER:$CHIMES_FTP_PASSWORD" --ftp-create-dirs \;