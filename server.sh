#!/usr/bin/env bash
SDIR=$(dirname -- "$(readlink -ne -- "$0")")	#Full SDIR
source "$SDIR/lib/functions/all.sh"

basename -- "$(readlink -e -- "$ETCDIR/default")"

