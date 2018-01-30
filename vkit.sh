#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
exists() { type "$1" >/dev/null 2>&1;}
die() { echo -e "$@">&2; exit 1; }
usage() {
	NAME=$(basename -s .sh "$0")
	echo "List backup versions of a given file"
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

echo "Please wait... this may take a while"
bash "$SDIR/versions.sh" "${OPTIONS[@]}" -- --dry-run --filter=": .rsync-filter" "${RSYNCOPTIONS[@]}" "$@"
