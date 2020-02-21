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

echo "Start Restore"

bash "$sdir/restore.sh" ${options+"${options[@]}"} -- --filter=": .rsync-filter" ${rsyncoptions+"${rsyncoptions[@]}"} "${@:-.}"
