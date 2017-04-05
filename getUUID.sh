#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR
[[ $1 == '-log' ]] && shift && exec 1>"$1" && shift

exists() { type "$1" >/dev/null 2>&1;}
die() { echo -e "$@">&2; exit 1; }

[[ -n $1 ]] || die "Usage:\n\t$0 path [mapdrive]"
[[ -e $1 ]] || die Cannot find $1

BACKUPDIR="$1"

exists cygpath && BACKUPDIR=$(cygpath "$1")

BACKUPDIR=$(readlink -ne "$BACKUPDIR")

VOLUMESERIALNUMBER=$(bash "$SDIR/drive.sh" "$BACKUPDIR"|cut -d'|' -f2)

echo "$VOLUMESERIALNUMBER"
