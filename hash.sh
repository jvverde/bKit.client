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
		--root=*)
			ROOT="${KEY#*=}"
			OPTIONS+=( "$KEY" )
		;;
		*=*)
			OPTIONS+=( "$KEY" )
		;;
		*)
			OPTIONS+=( "$KEY" "$1" ) && shift
		;;
	esac
done

SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR

IFS="
"
FULLPATHS=( $(readlink -e "$@") )

[[ -n $ROOT ]] || {
	MOUNT=( $(stat -c %m "${FULLPATHS[@]}") )

	ROOT=${MOUNT[0]}
	for M in "${MOUNT[@]}"
	do
		[[ $M == $ROOT ]] || die 'All directories/file must belongs to same logical disk'
	done
}

#pushd "$MOUNT" > /dev/null
bash "$SDIR/whoShouldUpdate.sh" "${OPTIONS[@]}" -- "${RSYNCOPTIONS[@]}" "${FULLPATHS[@]}"|
awk -F'|' '$1 ~ /^<f/ {print $3}' | tr '\n' '\0' |
xargs -r0 sha256sum -b|sed -E 's/\s+\*/|/' |
while IFS='|' read -r HASH FILE
do
	RFILE=${FILE#$ROOT}  	#remove mounting point (ROOT could be just a slash, so don't try to remove "$ROOT/")
	RFILE=${RFILE#/} 		#remove any leading slash if any
	echo "$HASH|$(stat -c '%s|%Y' "$FILE")|$RFILE"
done | sed -n '/^[^|]*[|][^|]*[|][^|]*[|][^|]*$/p'

#popd > /dev/null
