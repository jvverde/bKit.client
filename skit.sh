#!/usr/bin/env bash
sdir="$(dirname -- "$(readlink -f "$0")")"				#Full DIR

source "$sdir/lib/functions/all.sh"

declare -a filters=()


excludes(){

	declare -r exclist="$VARDIR/excludes/excludes.lst"

	[[ -e "$exclist" ]] || {
		echo Compile exclude list for the first time
		mkdir -pv "${exclist%/*}"
		bash "$sdir/lib/tools/excludes.sh" "$sdir/excludes" >  "$exclist"
	}
	[[ -n $(find "$exclist" -mtime +30) || ${compile+isset} == isset ]] && {
		echo Recompile exclude list
		bash "$sdir/lib/tools/excludes.sh" "$sdir/excludes" >  "$exclist"
	}

	filters+=( --filter=". $exclist" )
}

importrules(){
	[[ -e $sdir/rules/global ]] || mkdir -pv "$sdir/rules/global"
	#bash "$sdir/update.sh" "rules/global" "$sdir" >/dev/null
	bash "$sdir/update.sh" "rules/global" "$sdir"
	for F in $(ls "$sdir/rules/global")
	do
		filters+=( --filter=". $sdir/rules/global/$F" )
	done
}

ARGS=("$@")
options=()

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
			declare -r ALL=1
		;;
		--no-import)
			NO_IMPORT=1
		;;
		-c|--compile)
			declare -r compile=1
		;;
		--ignore-filters)
			nofilters=1
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
			options+=( "$KEY")
		;;
		*=*)
			options+=( "$KEY")
		;;
		*)
			options+=( "$KEY" "$1" ) && shift
		;;
	esac
done

[[ $# -eq 0 ]] && usage

#Don't move up in order to allow help/usage msg
[[ -n $NOASK ]] || {
	#run as sudo if user is not root and os is not cygwin
	[[ $OS == cygwin || $UID -eq 0 ]] || exec sudo "$0" "${ARGS[@]}"
	[[ $OS == cygwin ]] && !(id -G|grep -qE '\b544\b') && {	#if cygwin and not Administrator
		#https://cygwin.com/ml/cygwin/2015-02/msg00057.html
		echo I am going to runas Administrator
		WDIR=$(cygpath -w "$sdir")
		cygstart --wait --action=runas "$WDIR/skit.bat" --start-in="$(pwd)" "${ARGS[@]}"
		exit
	}
}

#Use excludes unless we want to snapshot everything
[[ ${ALL+isset} == isset ]] || excludes

#Until i think a little bit better about this, comment out next line
#[[ -n $NO_IMPORT ]] || importrules

[[ -n $nofilters ]] || filters+=( --filter=": .rsync-filter" )

echo Start snapshot backup for "${@:-.}" @"$(date -Imin)" 
#echo options="${options[@]}"
#echo RSYNCOPTIONS="${RSYNCOPTIONS[@]}"
#echo "$sdir/snapshot.sh" "${options[@]}" -- "${filters[@]}" "${RSYNCOPTIONS[@]}" "${@:-.}"
bash "$sdir/snapshot.sh" "${options[@]}" -- "${filters[@]}" "${RSYNCOPTIONS[@]}" "${@:-.}" 2>&1
echo Done snapshot backup for "${@:-.}" @"$(date -Imin)" 

