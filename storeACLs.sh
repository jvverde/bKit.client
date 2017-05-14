#!/bin/bash
die() { echo -e "$@">&2; exit 1; }
warn() { echo -e "$@">&2; }

PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH

type cygpath >/dev/null 2>&1 || die Cannot found cygpath

SDIR=$(cygpath "$(dirname "$(readlink -f "$0")")")	#Full DIR

while [[ $1 =~ ^- ]]
do
	KEY="$1" && shift
	case "$KEY" in
		--diracl=*)
			DIRACL="${KEY#*=}"
		;;
		--diracl)
			DIRACL="$1" && shift
		;;
		*)
			die "Usage: $0 [--diracl=name] files"
		;;
	esac
done

DIRACL=${DIRACL:-'.bkit-dir-acl'}

TARGETDIR=$(readlink -nm "$(cygpath "$1")")

[[ -d $TARGETDIR ]]  || mkdir -p "$TARGETDIR" || die Cannot create dir $ACLSDIR

SUBINACL=$(find "$SDIR/3rd-party" -type f -name "subinacl.exe" -print -quit)
[[ -f $SUBINACL ]] || die SUBINACL.exe not found

RESULT="$SDIR/run/store-$$/"
trap "rm -rf '$RESULT'" EXIT
mkdir -p "$RESULT"

getacl(){
	local SRC=$1
	[[ -L $SRC ]] && return 0
	local DST=$2
	[[ -d $SRC ]] && DST="$DST/$DIRACL"
	local PARENT=${DST%/*}
	[[ -d $PARENT ]] || mkdir -p "$PARENT"
	DOSSRC="$(cygpath -w "${SRC%/*}")\\${SRC##*/}" #we need go this way because symbolic links
	"$SUBINACL" /noverbose /nostatistic /onlyfile "$DOSSRC" | iconv -f UTF-16LE -t UTF-8| grep -Pio '^/.+' > "$DST"
	#copy attributes, but only for files, not directories
	{
		echo "+FILE $(cygpath -w "$2")"
		cat "$DST"
	} | iconv -f UTF-8 -t UTF-16LE > "$RESULT/acls"
	"$SUBINACL" /noverbose /nostatistic /playfile "$(cygpath -w "$RESULT/acls")"
	#don't change the order
	[[ $2 == $DST ]] && {
		cp --preserve=all --attributes-only "$(cygpath -u "$SRC")" "$DST" || warn "Cannot copy attributes from $SRC to $DST"
	}
}

while read -r DIR
do
	#echo DIR=$DIR
	#DIR=$(readlink -nm "$DIR")
	#echo DIR2=$DIR
	#WFULLPATH=$(cygpath -w "$DIR")
	#echo WFULL=$WFULLPATH
	RPATH=${DIR#/cygdrive/?/}
	DST=$TARGETDIR/$RPATH
	#echo DST=$DST
	getacl "$DIR" "$DST"
done
