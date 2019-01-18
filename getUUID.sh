#!/usr/bin/env bash
SDIR=$(dirname -- "$(readlink -en -- "$0")")	#Full SDIR
source "$SDIR/functions/all.sh"

[[ $1 == '-log' ]] && shift && exec 1>"$1" && shift

[[ -n $1 ]] || die "Usage:\n\t$0 path [mapdrive]"
[[ -e $1 ]] || die Cannot find $1

BACKUPDIR="$1"

exists cygpath && BACKUPDIR=$(cygpath "$1")

BACKUPDIR=$(readlink -ne "$BACKUPDIR")

VOLUMESERIALNUMBER=$(bash "$SDIR/drive.sh" "$BACKUPDIR"|cut -d'|' -f2)

echo "$VOLUMESERIALNUMBER"
