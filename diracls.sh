#!/usr/bin/env bash

type cygpath >/dev/null 2>&1 || die Cannot found cygpath
SDIR="$(dirname -- "$(readlink -ne -- "$0")")"
source "$SDIR/lib/functions/all.sh"
SDIR="$(cygpath "$SDIR")"

TARGETDIR=$(readlink -nm "$(cygpath "${@: -1}")")

[[ -d $TARGETDIR ]]  || mkdir -pv "$TARGETDIR" || die Cannot create dir $ACLSDIR

SUBINACL=$(find "$SDIR/3rd-party" -type f -name "subinacl.exe" -print -quit)
[[ -f $SUBINACL ]] || die SUBINACL.exe not found

acldir(){
	local WSPATH=$(cygpath -w "$1")
	local WACLSFILE=$(cygpath -w "$2")
	local WSIDSFILE=$(cygpath -w "$3")
	"$SUBINACL" /noverbose /nostatistic /output="$WACLSFILE" /dumpcachedsids="$WSIDSFILE" /onlyfile "$WSPATH"
	"$SUBINACL" /noverbose /nostatistic /output="$WACLSFILE.tmp" /dumpcachedsids="$WSIDSFILE.tmp" /file=filesonly "$WSPATH\\*"
	cat "$WACLSFILE.tmp" >> "$WACLSFILE" && rm "$WACLSFILE.tmp"
	cat "$WSIDSFILE.tmp" >> "$WSIDSFILE" && rm "$WSIDSFILE.tmp"
}

for DIR in "${@:1:$#-1}"
do
	[[ ! -d $DIR ]]  && warn "'$DIR' is not a directory" && continue

	SRCDIR=$(readlink -ne "$(cygpath "$DIR")")

	ROOT=$(stat -c%m "$SRCDIR")

	ACLSDIR=${TARGETDIR%/}${SRCDIR#$ROOT}
	ACLSDIR=${ACLSDIR%/} 	#remove trailing slash if any

	mkdir -pv "$ACLSDIR" || die Cannot create dir $ACLSDIR

	acldir "$SRCDIR" "$ACLSDIR/.bkit-acls" "$ACLSDIR/.bkit-sids"

	echo ACLS done for $DIR
done
