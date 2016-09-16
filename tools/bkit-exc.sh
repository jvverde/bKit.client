#!/bin/bash
FILE=${1:--}
BKITDIR="$(dirname "$(readlink -f "$0../")")"
type cygpath >/dev/null 2>&1 && BKITDIR=$(cygpath -u "$BKITDIR")
cat "$FILE"|awk -v BKITDIR="$BKITDIR/" '{print BKITDIR $0}'|sed 's|^/cygdrive/./|/cygdrive/?/|'