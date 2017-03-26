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
			die Unknow	option $KEY
		;;
	esac
done

SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR

FULLPATH="$(readlink -e "$1")"

[[ -d $FULLPATH ]] || die Directory $FULLPATH does not exists

MOUNT="$(stat -c %m "$FULLPATH")"
DIR="${FULLPATH#$MOUNT/}"

VOLUMESERIALNUMBER=$("$SDIR/drive.sh" "$FULLPATH" 2>/dev/null |cut -d'|' -f2)

CACHE="$SDIR/cache/hashes/by-volume/$VOLUMESERIALNUMBER/$DIR"

[[ -d $CACHE ]] || mkdir -p "$CACHE"

pushd "$MOUNT" > /dev/null

"$SDIR/whoShouldUpdate.sh" -- "${RSYNCOPTIONS[@]}" "$FULLPATH" |
awk -F'|' '$1 ~ /^<f/ {print $2}' |
xargs -r sha256sum -b|sed -E 's/\s+\*/|/' |
while IFS='|' read -r HASH FILE
do
	echo "$HASH|$(stat -c '%s|%Y' "$FILE")|$FILE"
done | sed -n '/^[^|]*[|][^|]*[|][^|]*[|][^|]*$/p'

popd > /dev/null

