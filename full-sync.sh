#!/bin/bash

set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/load-ftp-secrets.sh"

lftp -c "
    set ssl:verify-certificate no
    set ftp:list-options -a
    open ftp://$CHIMES_FTP_HOST
    user $CHIMES_FTP_USER $CHIMES_FTP_PASSWORD
    lcd dist
    mirror -R --delete --verbose --parallel=3 . /
"