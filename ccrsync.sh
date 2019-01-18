#!/usr/bin/env bash
#RSYNC Common Code
SDIR="$(dirname -- "$(readlink -ne -- "$0")")"
source "$SDIR/functions/all.sh"

RSYNCOPTIONS=()

[[ ${BKIT_CONFIG+isset} == isset && -e $BKIT_CONFIG ]] || {
	BKIT_CONFIG="$ETCDIR/default/conf.init"
}

[[ -e $BKIT_CONFIG ]] || die "Can't source file $BKIT_CONFIG"

source "$BKIT_CONFIG"

[[ -e $PASSFILE ]] && export RSYNC_PASSWORD="$(<${PASSFILE})" || die "Pass file not found on location '$PASSFILE'"
[[ -n $SSH ]] && export RSYNC_CONNECT_PROG="$SSH"
