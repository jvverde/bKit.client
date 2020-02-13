#!/usr/bin/env bash

type cygpath >/dev/null 2>&1 || die Cannot found cygpath
SDIR=$(cygpath "$(dirname -- "$(readlink -en -- "$0")")")	#Full DIR
source "$SDIR/lib/functions/all.sh"

RSYNCOPTIONS=(
  --groupmap=4294967295:$(id -u)
  --usermap=4294967295:$(id -g)
  --numeric-ids
  --super
)

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

TARGETDIR="$(cygpath "$(readlink -nm "$1")")"

[[ -d $TARGETDIR ]]  || mkdir -p "$TARGETDIR" || die Cannot create dir $ACLSDIR

SUBINACL=$(find "$SDIR/3rd-party" -type f -name "subinacl.exe" -print -quit)
[[ -f $SUBINACL ]] || die SUBINACL.exe not found

mktempdir RESULT

ERRFILE="$VARDIR/acls-$(date +%Y-%m-%dT%H-%M-%S).err"
exec 2>"$ERRFILE"

finish() {
	rm -rf '$RESULT'
	[[ -s $ERRFILE ]] || rm -f '$ERRFILE'
}

atexit finish

getacl(){
	local SRC=$1
	[[ -L $SRC ]] && return 0
	local DST=$2
	local PARENT="${DST%/*}"
	[[ -d $PARENT ]] || mkdir -pv "$PARENT"

	[[ -d $SRC ]] && {
		rsync -idpogAt "${RSYNCOPTIONS[@]}" "${SRC%/}" "${DST%/*}" #update directory only
		DST="$DST/$DIRACL"
	}
	[[ -d $SRC ]] || cp --preserve=all --attributes-only -v "$SRC" "$DST"
	DOSSRC="$(cygpath -w "${SRC%/*}")\\${SRC##*/}" #we need go this way because symbolic links
	local DT=$(date -R -r "$SRC")
	"$SUBINACL" /noverbose /nostatistic /onlyfile "$DOSSRC" | iconv -f UTF-16LE -t UTF-8| grep -Pio '^/.+' > "$DST"
	touch -d "$DT" "$DST"
}

while read -r ENTRY
do
	ENTRY=$(readlink -e "$ENTRY") || continue
	RPATH=${ENTRY#/cygdrive/?}
	DST=$TARGETDIR/${RPATH#/}
	getacl "$ENTRY" "$DST"
done
