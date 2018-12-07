#!/usr/bin/env bash
#compute hash values for missing files on bkit server
#output on form a/b/c/d/e/f/[0-9a-f]{58}|size|time|relative path on server side
#:ex: 1/3/2/0/2/5/750401dd51cd5ba7a44dd7adcb9d4fc7f2e59df4bacf39c7da178868a3|180|1543680565|bkit/scripts/client/conf/tmp/sshkey.pub
die() { echo -e "$@">&2; exit 1; }
exists() { type "$1" >/dev/null 2>&1 ;}

SDIR="$(dirname -- "$(readlink -f -- "$0")")"				#Full DIR

OPTIONS=()
while [[ $1 =~ ^- ]]
do
        KEY="$1" && shift
        case "$KEY" in
                *)
                        OPTIONS+=( "$KEY" ) 
                ;;
        esac
done


(( $# == 0 )) && die "Usage:\n\t$0 dirs" 

for DIR in "$@"
do
	FULLPATH="$(readlink -e -- "$DIR")" || continue

	ROOT="$(stat -c %m "$FULLPATH")"

	bash "$SDIR/needUpdate.sh" "${OPTIONS[@]}" --out-format='%i|/%f' "$FULLPATH"|
	awk -F'|' '$1 ~ /^<f/ {print $2}' | tr '\n' '\0' |
	xargs -r0 sha256sum -b|sed -E 's/\s+\*/|/' |
	while IFS='|' read -r HASH FILE
	do
		RFILE=${FILE#$ROOT}  	#remove mounting point (ROOT could be just a slash, so don't try to remove "$ROOT/")
		RFILE=${RFILE#/} 	#remove any leading slash if any
		echo "$HASH|$(stat -c '%s|%Y' "$FILE")|$RFILE"
	done | sed -rn 's#^(.)(.)(.)(.)(.)(.)#\1/\2/\3/\4/\5/\6/#p'
done
