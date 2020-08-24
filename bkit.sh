#!/usr/bin/env bash
set -uE
sdir="$(dirname -- "$(readlink -ne -- "$0")")"				#Full DIR
source "$sdir/lib/functions/all.sh"

usage() {
	local name=$(basename -s .sh "$0")
	echo Backup one or more directories or files
	echo -e "Usage:\n\t $name [-a|--all] [-c|--compile] [--ignore-filters] [--stats] dir1/file1 [[dir2/file2 [...]]"
	exit 1
}

declare -a filters=()

excludes(){

	declare -r exclist="$VARDIR/excludes/excludes.lst"

	[[ -e "$exclist" ]] || {
		echo Compile exclude list
		mkdir -pv "${exclist%/*}"
		bash "$sdir/lib/tools/excludes.sh" "$sdir/excludes" |sed -E 's/ +$//' >  "$exclist"
	}
	[[ -n $(find "$exclist" -mtime +30) || ${compile+isset} == isset ]] && {
		echo Recompile exclude list
		bash "$sdir/lib/tools/excludes.sh" "$sdir/excludes" |sed -E 's/ +$//' >  "$exclist"
	}

	filters+=( --filter=". $exclist" )
}

declare -a options=() rsyncoptions=()

while [[ ${1:-} =~ ^- ]]
do
	key="$1" && shift
	case "$key" in
		-- )
			while [[ ${1:-} =~ ^- ]]
			do
				rsyncoptions+=( "$1" )
				shift
			done
		;;
		-a|--all)
			all=1
		;;
		-c|--compile)
			compile=1
		;;
		--ignore-filters)
			nofilters=1
		;;
		-h|--help)
			usage
		;;
		--stats|--sendlogs|--notify)
			options+=( "$key")
		;;
		*)
			options+=( "$key")
		;;
	esac
done

#(( $# == 0 )) && usage

[[ ${all+isset} == isset ]] || excludes

[[ ${nofilters+isset} == isset ]] || filters+=( --filter=": .rsync-filter" )

declare -r pgid="$(cat /proc/self/pgid 2>/dev/null)"
echo "bKit[$$:$pgid]: Start backup for ${@:-.}"
let cnt=16
let sec=60
while (( cnt-- > 0 ))
do
	bash "$sdir/backup.sh" ${options+"${options[@]}"} -- ${filters+"${filters[@]}"} ${rsyncoptions+"${rsyncoptions[@]}"} "${@:-.}" && break
	let delay=(1 + RANDOM % $sec)
	echo "bKit:Wait $delay seconds before try again"
	sleep $delay
	let sec=2*sec
done
echo "bKit[$$:$pgid]: Done"
