#!/usr/bin/env bash
die() { echo -e "$@">&2; exit 1; }
warn() { echo -e "$@">&2; }

PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH

type cygpath >/dev/null 2>&1 || die Cannot found cygpath

SDIR=$(cygpath "$(dirname "$(readlink -f "$0")")")	#Full DIR

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
