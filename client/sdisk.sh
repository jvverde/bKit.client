#!/usr/bin/env bash
sdir="$(dirname -- "$(readlink -ne -- "$0")")"       #Full DIR

source "$sdir/ccrsync.sh"

rsync --list-only "$BACKUPURL"


