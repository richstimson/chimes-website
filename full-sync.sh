#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$SCRIPT_DIR/deploy-guards.sh"
require_deploy_guards

source "$SCRIPT_DIR/deploy-target.sh"

lftp -c "
    $CHIMES_LFTP_OPEN
    lcd dist
    mirror -R --delete --verbose --parallel=3 \
        --exclude-glob _astro \
        --exclude-glob _astro/* \
        --exclude-glob _astro/** \
        --exclude-glob .well-known/ \
        --exclude-glob .ftpquota \
        . $CHIMES_REMOTE_ROOT
    lcd _astro
    mirror -R --verbose --parallel=3 \
        . $CHIMES_REMOTE_ROOT/_astro
"
