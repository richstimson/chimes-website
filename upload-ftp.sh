#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$SCRIPT_DIR/deploy-guards.sh"
require_deploy_guards

source "$SCRIPT_DIR/load-ftp-secrets.sh"

cd dist
find . -type f -exec curl -T {} "ftp://$CHIMES_FTP_HOST/{}" --user "$CHIMES_FTP_USER:$CHIMES_FTP_PASSWORD" --ftp-create-dirs \;