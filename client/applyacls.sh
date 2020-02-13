#!/usr/bin/env bash
type cygpath >/dev/null 2>&1 || die Cannot found cygpath
SDIR=$(cygpath "$(dirname -- "$(readlink -ne -- "$0")")")	#Full DIR
source "$SDIR/lib/functions/all.sh"

SUBINACL=$(find "$SDIR/3rd-party" -type f -name "subinacl.exe" -print -quit)
[[ -f $SUBINACL ]] || die SUBINACL.exe not found

for FILE in "$@"
do
	SRC=$(cygpath -w $(readlink -en -- "$FILE"))
	"$SUBINACL" /nostatistic /playfile "$SRC"
done
