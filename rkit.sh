#!/usr/bin/env bash
SDIR=$(dirname -- "$(readlink -en -- "$0")")	#Full SDIR
source "$SDIR/functions/all.sh"

usage() {
	bash "$SDIR/restore.sh" --help="$(basename -s .sh "$0")"
	exit 1;
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

SDIR="$(dirname -- "$(readlink -ne -- "$0")")"				#Full DIR

(( $# == 0 )) && usage

echo "Start Restore"

bash "$SDIR/restore.sh" "${OPTIONS[@]}" -- --filter=": .rsync-filter" "${RSYNCOPTIONS[@]}" "$@"
