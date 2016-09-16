#!/bin/bash
FILE=${1:--}
BKITDIR="$(dirname "$(readlink -f "$0../")")"
cat "$FILE"|awk -v BKITDIR="$BKITDIR/" '{print BKITDIR $0}'|sed 's|^/cygdrive/./||'
