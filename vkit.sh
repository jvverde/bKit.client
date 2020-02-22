#!/usr/bin/env bash
declare -r sdir=$(dirname -- "$(readlink -en -- "$0")")	#Full sdir
source "$sdir/lib/functions/all.sh"

usage() {
	declare -r name=$(basename -s .sh "$0")
	echo "List backup versions of a given file"
	echo -e "Usage:\n\t $name dir1/file1 [[dir2/file2 [...]]"
	exit 1
}

declare -a options=()
declare -a rsyncoptions=()
while [[ $1 =~ ^- ]]
do
	key="$1" && shift
	case "$key" in
		-- )
			while [[ $1 =~ ^- ]]
			do
				rsyncoptions+=( "$1" )
				shift
			done
		;;
		-h|--help)
			usage
		;;
		*)
			options+=( "$key" )
		;;
	esac
done

echo "Please wait... this may take a while" >&2
bash "$sdir/versions.sh" ${options+"${options[@]}"} -- --dry-run --filter=": .rsync-filter" ${rsyncoptions+"${rsyncoptions[@]}"} "${@:-.}"
