#!/bin/bash

# Upload every file in dist/ to the live site. Deletes nothing on the server;
# use full-sync.sh or sync-smart.sh to remove files that are no longer built.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$SCRIPT_DIR/deploy-guards.sh"
require_deploy_guards

source "$SCRIPT_DIR/deploy-target.sh"

lftp -c "
    $CHIMES_LFTP_OPEN
    lcd dist
    mirror -R --verbose --parallel=3 . $CHIMES_REMOTE_ROOT
"
