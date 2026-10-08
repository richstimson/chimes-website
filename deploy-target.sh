#!/bin/bash

# Where and how the deploy scripts reach the live site: SFTP with an SSH key.
# The Bluehost account has no shell access, so rsync is not available; lftp
# mirrors over SFTP instead. No password is involved.
#
# Each setting can be overridden from the environment.

CHIMES_SSH_HOST="${CHIMES_SSH_HOST:-box2276.bluehost.com}"
CHIMES_SSH_USER="${CHIMES_SSH_USER:-stimsons}"
CHIMES_SSH_KEY="${CHIMES_SSH_KEY:-$HOME/.ssh/chimes_deploy_ed25519}"

# Document root for chimesapp.com, an addon domain on the account.
CHIMES_REMOTE_ROOT="${CHIMES_REMOTE_ROOT:-/home1/stimsons/public_html/chimesapp}"

if [ ! -f "$CHIMES_SSH_KEY" ]; then
    echo "❌ SSH key not found: $CHIMES_SSH_KEY"
    echo "   See 'Deploy access' in DEPLOYMENT.md, or set CHIMES_SSH_KEY."
    return 1 2>/dev/null || exit 1
fi

# lftp commands that open the SFTP connection. BatchMode makes ssh fail
# instead of prompting; the empty password after "-u user," stops lftp asking.
CHIMES_LFTP_OPEN="set sftp:connect-program 'ssh -a -x -o BatchMode=yes -o IdentitiesOnly=yes -i $CHIMES_SSH_KEY'
open -u $CHIMES_SSH_USER, sftp://$CHIMES_SSH_HOST"
