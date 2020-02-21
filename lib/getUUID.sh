#!/usr/bin/env bash
#As the name says. Get thee UUId of partion/volume of a given path

set -u
sdir=$(dirname -- "$(readlink -en -- "$0")")	#Full sdir
source "$sdir/functions/all.sh"

[[ ${1+isset} == isset ]] || die "Usage:\n\t$0 path"
[[ -e $1 ]] || die Cannot find $1

backupdir="$1"

exists cygpath && backupdir=$(cygpath "$1")

backupdir=$(readlink -ne "$backupdir")

uuid=$(bash "$sdir/drive.sh" "$backupdir"|cut -d'|' -f2)

echo "$uuid"