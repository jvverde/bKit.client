#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
die() { echo -e "$@">&2; exit 1; }
exists() { type "$1" >/dev/null 2>&1 ;}


RSYNCOPTIONS=()
while [[ $1 =~ ^- ]]
do
	KEY="$1" && shift
	case "$KEY" in
		-- )
			while [[ $1 =~ ^- ]]
			do
				RSYNCOPTIONS+=("$1")
				shift
			done
		;;
		*)
			die Unknown	option $KEY
		;;
	esac
done

SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR

IFS="
"
FULLPATHS=( $(readlink -e "$@") )

MOUNT="$(stat -c %m "${FULLPATHS[0]}")"

pushd "$MOUNT" > /dev/null

bash "$SDIR/whoShouldUpdate.sh" -- "${RSYNCOPTIONS[@]}" "${FULLPATHS[@]}" |
awk -F'|' '$1 ~ /^<f/ {print $2}' | tr '\n' '\0' |
xargs -r0 sha256sum -b|sed -E 's/\s+\*/|/' |
while IFS='|' read -r HASH FILE
do
	echo "$HASH|$(stat -c '%s|%Y' "$FILE")|$FILE"
done | sed -n '/^[^|]*[|][^|]*[|][^|]*[|][^|]*$/p'

popd > /dev/null