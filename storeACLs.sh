#!/bin/bash
die() { echo -e "$@">&2; exit 1; }
warn() { echo -e "$@">&2; }

PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH

type cygpath >/dev/null 2>&1 || die Cannot found cygpath

SDIR=$(cygpath "$(dirname "$(readlink -f "$0")")")	#Full DIR

TARGETDIR=$(readlink -nm "$(cygpath "${@: -1}")")

[[ -d $TARGETDIR ]]  || mkdir -p "$TARGETDIR" || die Cannot create dir $ACLSDIR

SUBINACL=$(find "$SDIR/3rd-party" -type f -name "subinacl.exe" -print -quit)
[[ -f $SUBINACL ]] || die SUBINACL.exe not found

getacl(){
	local SRC=$1
	local DST=$2
	[[ -d $SRC ]] && DST="$DST/.bkit-dir-acl"
	local PARENT=${DST%/*}
	[[ -d $PARENT ]] || mkdir -p "$PARENT"
	"$SUBINACL" /noverbose /nostatistic /onlyfile "$SRC" | iconv -f UTF-16LE -t UTF-8| grep -Pio '^/.+' > "$DST"
}

for DIR in "${@:1:$#-1}"
do
	DIR=$(readlink -nm "$DIR")
	FULLPATH=$(cygpath -w "$DIR")
	RPATH=$(cygpath -u "${FULLPATH#?:\\}")
	DST=$TARGETDIR/$RPATH
	getacl "$FULLPATH" "$DST"
done
