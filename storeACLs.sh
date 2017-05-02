#!/bin/bash
die() { echo -e "$@">&2; exit 1; }
warn() { echo -e "$@">&2; }

PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH

type cygpath >/dev/null 2>&1 || die Cannot found cygpath

SDIR=$(cygpath "$(dirname "$(readlink -f "$0")")")	#Full DIR

TARGETDIR=$(readlink -nm "$(cygpath "${@: -1}")")

[[ -d $TARGETDIR ]]  || mkdir -pv "$TARGETDIR" || die Cannot create dir $ACLSDIR

SUBINACL=$(find "$SDIR/3rd-party" -type f -name "subinacl.exe" -print -quit)
[[ -f $SUBINACL ]] || die SUBINACL.exe not found

getacl(){
	local SRC=$(cygpath -w "$1")
	local DST=$2
	[[ -d $1 ]] && DST="$DST/.bkit-dir-acl"
	local PARENT=${DST%/*}
	[[ -d $PARENT ]] || mkdir -pv "$PARENT"
	DST=$(cygpath -w "$DST")
	"$SUBINACL" /noverbose /nostatistic /output="$DST" /onlyfile "$SRC"
}

for DIR in "${@:1:$#-1}"
do
	DIR=$(readlink -nm "$DIR")
	FULLPATH=$(cygpath -w "$DIR")
	RPATH=$(cygpath -u "${FULLPATH#?:\\}")
	DST=$TARGETDIR/$RPATH
	getacl "$FULLPATH" "$DST"
done
