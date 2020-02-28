#!/usr/bin/env bash
#RSYNC Common Code
declare rccdir="$(dirname -- "$(readlink -ne -- "${BASH_SOURCE[0]}")")"
source "$rccdir/lib/functions/all.sh"

[[ ${BKIT_CONFIG+isset} == isset && -e $BKIT_CONFIG ]] || {
	BKIT_CONFIG="$ETCDIR/server/default/conf.init"
}

[[ -e $BKIT_CONFIG ]] || die "Can't source file '$BKIT_CONFIG'"

source "$BKIT_CONFIG"

[[ -e $PASSFILE ]] && export RSYNC_PASSWORD="$(<${PASSFILE})" || die "Pass file not found on location '$PASSFILE'"

[[ ${NOSSH+isset} == isset ]] && {
	unset RSYNC_CONNECT_PROG
	BACKUPURL="$RSYNCURL"
} || {
	export RSYNC_CONNECT_PROG="$SSH"
  BACKUPURL="$SSHURL"
}
