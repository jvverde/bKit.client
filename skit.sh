#!/usr/bin/env bash
sdir="$(dirname -- "$(readlink -f "$0")")"				#Full DIR

source "$sdir/lib/functions/all.sh"

declare -a filters=()

excludes(){

	declare -r exclist="$VARDIR/excludes/excludes.lst"

	[[ -e "$exclist" ]] || {
		echo Compile exclude list for the first time
		mkdir -pv "${exclist%/*}"
		bash "$sdir/lib/tools/excludes.sh" "$sdir/excludes" |sed -E 's/ +$//' >  "$exclist"
	}
	[[ -n $(find "$exclist" -mtime +30) || ${compile+isset} == isset ]] && {
		echo Recompile exclude list
		bash "$sdir/lib/tools/excludes.sh" "$sdir/excludes" |sed -E 's/ +$//' >  "$exclist"
	}

	filters+=( --filter=". $exclist" )
}

importrules(){
	[[ -e "$sdir/rules/global" ]] || mkdir -pv "$sdir/rules/global"
	#bash "$sdir/update.sh" "rules/global" "$sdir" >/dev/null
	bash "$sdir/update.sh" "rules/global" "$sdir"
	for F in $(ls "$sdir/rules/global")
	do
		filters+=( --filter=". '$sdir/rules/global/$F'" )
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
				rsyncoptions+=( "$1" )
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
		--vardir=*)
			export VARDIR="${KEY#*=}"
		;;
		--etcdir=*)
			export ETCDIR="${KEY#*=}"
		;;
		*=*)
			options+=( "$KEY")
		;;
		# *)
		# 	options+=( "$KEY" "$1" ) && shift
		# ;;
		-u|--uuid)
		 	options+=( "$KEY" "$1" ) && shift
		;;
		--logdir)
			options+=( "$KEY" "$1" ) && shift
		;;

		*)
			options+=( "$KEY")
		;;
	esac
done

[[ $# -eq 0 ]] && usage

#Don't move up in order to allow help/usage msg
[[ -n $NOASK ]] || {
	##run as sudo if user is not root and os is not cygwin
	#Until we realise we really need this, comment line bellow
	#[[ $OS == cygwin || $UID -eq 0 ]] || exec sudo "$0" "${ARGS[@]}"
	[[ $OS == cygwin ]] && !(id -G|grep -qE '\b544\b') && {	#if cygwin and not Administrator
		#https://cygwin.com/ml/cygwin/2015-02/msg00057.html
		echo I am going to run as Administrator
		WDIR=$(cygpath -w "$sdir")
		#echo cygstart --wait --action=runas "$WDIR/skit.bat" --start-in="$(pwd)" --etcdir="$ETCDIR" --vardir="$VARDIR" "${ARGS[@]}"
		cygstart --wait --action=runas "$WDIR/skit.bat" --start-in="$(pwd)" --etcdir="$ETCDIR" --vardir="$VARDIR" "${ARGS[@]}"
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
#echo rsyncoptions="${rsyncoptions[@]}"
#echo "$sdir/snapshot.sh" "${options[@]}" -- "${filters[@]}" "${rsyncoptions[@]}" "${@:-.}"
echo snapshot with ETCDIR=$ETCDIR
bash "$sdir/snapshot.sh" ${options[@]+"${options[@]}"} -- ${filters[@]+"${filters[@]}"} ${rsyncoptions[@]+"${rsyncoptions[@]}"} "${@:-.}" 2>&1
echo Done snapshot backup for "${@:-.}" @"$(date -Imin)" 
#read -t 60 -p "Hit ENTER or wait one minute"
