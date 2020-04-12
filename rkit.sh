#!/usr/bin/env bash
set -u
declare -r sdir=$(dirname -- "$(readlink -en -- "$0")")	#Full sdir
source "$sdir/lib/functions/all.sh"

usage() {
	bash "$sdir/restore.sh" --help="$(basename -s .sh -- "$0")"
	exit 1;
}

declare -a options=()
declare -a rsyncoptions=()

while [[ ${1:-} =~ ^- ]]
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

(( $# == 0 )) && usage

declare -r pgid="$(cat /proc/self/pgid 2>/dev/null)"
echo "rKit[$$:$pgid]: Start Restore for ${@:-.}"

if exists cygpath
then
	declare -a args=()
	for arg in "${@:-.}"
	do
	  args+=( "$(cygpath -u "$arg")" )
	done
else
	declare -ra args=("${@:-.}")
fi

bash "$sdir/restore.sh" ${options+"${options[@]}"} -- --filter=": .rsync-filter" ${rsyncoptions+"${rsyncoptions[@]}"} "${args[@]}"
echo "rKit[$$:$pgid]: Done"