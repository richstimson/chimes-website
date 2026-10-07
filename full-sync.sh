#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$SCRIPT_DIR/deploy-guards.sh"
require_deploy_guards

source "$SCRIPT_DIR/load-ftp-secrets.sh"

lftp -c "
    set ssl:verify-certificate no
    set ftp:list-options -a
    open ftp://$CHIMES_FTP_HOST
    user $CHIMES_FTP_USER $CHIMES_FTP_PASSWORD
    lcd dist
    mirror -R --delete --verbose --parallel=3 \
        --exclude-glob _astro \
        --exclude-glob _astro/* \
        --exclude-glob _astro/** \
        --exclude-glob .well-known/ \
        --exclude-glob .ftpquota \
        . /
    lcd _astro
    mirror -R --verbose --parallel=3 \
        . /_astro
"