#!/usr/bin/env bash
die() { echo -e "$@">&2; exit 1; }
exists() { type "$1" >/dev/null 2>&1 ;}

SDIR="$(dirname -- "$(readlink -f -- "$0")")"				#Full DIR

(( $# == 0 )) && die "Usage:\n\t$0 dirs" 

FULLPATH="$(readlink -e -- "$1")"

ROOT="$(stat -c %m "$FULLPATH")"

bash "$SDIR/needUpdate.sh" --out-format='%i|/%f' "$FULLPATH"|
awk -F'|' '$1 ~ /^<f/ {print $2}' | tr '\n' '\0' |
xargs -r0 sha256sum -b|sed -E 's/\s+\*/|/' |
while IFS='|' read -r HASH FILE
do
	RFILE=${FILE#$ROOT}  	#remove mounting point (ROOT could be just a slash, so don't try to remove "$ROOT/")
	RFILE=${RFILE#/} 	#remove any leading slash if any
	echo "$HASH|$(stat -c '%s|%Y' "$FILE")|$RFILE"
done | sed -n '/^[^|]*[|][^|]*[|][^|]*[|][^|]*$/p'

