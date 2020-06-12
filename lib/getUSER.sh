#!/usr/bin/env bash
set -u
declare -r sdir=$(dirname -- "$(readlink -en -- "$0")")	#Full sdir
source "$sdir/functions/all.sh"

echo "$BKITUSER"
