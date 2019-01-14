#!/usr/bin/env bash
SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR

source "$SDIR/functions/all.sh"


FILTERS=()

excludes(){
	EXCDIR=$SDIR/cache/excludes
	[[ -d $EXCDIR ]] || mkdir -p "$EXCDIR"

	EXCL=$EXCDIR/exclude.lst

	[[ -e "$EXCL" ]] || { #if not exist yet
		echo Compile exclude list
		:> "$EXCL"
		bash "$SDIR/tools/excludes.sh" "$SDIR/excludes" >  "$EXCL"
	}

	[[ -e "$EXCL" ]] && [[ -n $COMPILE || -n $(find "$EXCL" -mtime +30) ]] && {
		echo Recompile exclude list
		bash "$SDIR/tools/excludes.sh" "$SDIR/excludes" >  "$EXCL"
	}

	FILTERS+=( --filter=". $EXCL" )
}

importrules(){
	[[ -e $SDIR/rules/global ]] || mkdir -pv "$SDIR/rules/global"
	#bash "$SDIR/update.sh" "rules/global" "$SDIR" >/dev/null
	bash "$SDIR/update.sh" "rules/global" "$SDIR"
	for F in $(ls "$SDIR/rules/global")
	do
		FILTERS+=( --filter=". $SDIR/rules/global/$F" )
	done
}

ARGS=("$@")
OPTIONS=()
RSYNCOPTIONS=()

usage() {
	NAME=$(basename -s .sh "$0")
	echo Snapshot and backup one or more directories or files
	echo -e "Usage:\n\t $NAME [-a|--all] [-c|--compile] dir1/file1 [[dir2/file2 [...]]"
	exit 1
}

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
		-a|--all)
			ALL=1
		;;
		--no-import)
			NO_IMPORT=1
		;;
		-c|--compile)
			COMPILE=1
		;;
		--ignore-filters)
			NOFILTERS=1
		;;
		--start-in=*)
			cd "${KEY#*=}"
		;;
		--no-ask)
			NOASK=1
		;;
		-h|--help)
			usage
		;;
		--stats|--sendlogs|--notify)
			OPTIONS+=( "$KEY")
		;;
		*=*)
			OPTIONS+=( "$KEY")
		;;
		*)
			OPTIONS+=( "$KEY" "$1" ) && shift
		;;
	esac
done

[[ $# -eq 0 ]] && usage

#Don't move up in order to allow help/usage msg
[[ -n $NOASK ]] || {
	[[ $OS == cygwin || $UID -eq 0 ]] || exec sudo "$0" "${ARGS[@]}"
	[[ $OS == cygwin ]] && !(id -G|grep -qE '\b544\b') && {
		#https://cygwin.com/ml/cygwin/2015-02/msg00057.html
		echo I am going to runas Administrator
		WDIR=$(cygpath -w "$SDIR")
		cygstart --wait --action=runas "$WDIR/skit.bat" --start-in="$(pwd)" "${ARGS[@]}"
		exit
	}
}

[[ -n $ALL ]] || excludes
[[ -n $NO_IMPORT ]] || importrules

[[ -n $NOFILTERS ]] || FILTERS+=( --filter=": .rsync-filter" )

echo Start snapshot backup

bash "$SDIR/snapshot.sh" "${OPTIONS[@]}" -- "${FILTERS[@]}" "${RSYNCOPTIONS[@]}" "${@:-.}"
