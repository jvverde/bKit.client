#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
exists() { type "$1" >/dev/null 2>&1;}
die() { echo -e "$@">&2; exit 1; }
usage() {
	NAME=$(basename -s .sh "$0")
	echo Show differences to last backup
	echo -e "Usage:\n\t $NAME dir1/file1 [[dir2/file2 [...]]"
	exit 1
}

OPTIONS=()
RSYNCOPTIONS=()
while [[ $1 =~ ^- ]]
do
	KEY="$1" && shift
	case "$KEY" in
		-- )
			while [[ $1 =~ ^- ]]
			do
				RSYNCOPTIONS+=( "$1" )
				shift
			done
		;;
		-h|--help)
			usage
		;;
		*)
			OPTIONS+=( "$KEY" )
		;;
	esac
done

SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR

[[ $# -eq 0 ]] && usage

bash "$SDIR/whoShouldUpdate.sh" "${OPTIONS[@]}" --out-format="%i|%M|%l|/%f"  -- --filter=": .rsync-filter" "${RSYNCOPTIONS[@]}" "$@"|
while IFS='|' read I TIME SIZE FILE
do
	exists cygpath && FILE=$(cygpath -w "$FILE")
	echo "$I|$TIME|$SIZE|$FILE"
done
