#!/usr/bin/env bash
#RSYNC Common Code
sdir="$(dirname -- "$(readlink -ne -- "${BASH_SOURCE[0]}")")"
source "$sdir/lib/functions/all.sh"

declare -a RSYNCOPTIONS=()

[[ ${BKIT_CONFIG+isset} == isset && -e $BKIT_CONFIG ]] || {
	BKIT_CONFIG="$ETCDIR/default/conf.init"
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
