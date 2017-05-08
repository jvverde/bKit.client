#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR
OS=$(uname -o |tr '[:upper:]' '[:lower:]')
exists() { type "$1" >/dev/null 2>&1;}
die() { echo -e "$@">&2; exit 1; }
usage() {
	NAME=$(basename -s .sh "$0")
	echo Snapshot and backup one or more directories or files
	echo -e "Usage:\n\t $NAME [-a|--all] [-c|--compile] dir1/file1 [[dir2/file2 [...]]"
	exit 1
}


FILTERS=()

excludes(){
	EXCDIR=$SDIR/cache/excludes
	[[ -d $EXCDIR ]] || mkdir -p $EXCDIR

	EXCL=$EXCDIR/exclude.lst

	[[ -e "$EXCL" ]] || { #if not exist yet
		echo Compile exclude list
		bash "$SDIR/tools/excludes.sh" "$SDIR/excludes" >  "$EXCL"
	}

	[[ -n $COMPILE || -n $(find "$EXCL" -mtime +30) ]] && {
		echo Recompile exclude list
		bash "$SDIR/tools/excludes.sh" "$SDIR/excludes" >  "$EXCL"
	}

	FILTERS+=( --filter=". $EXCL" )
}

RUNDIR="$SDIR/run"
RULESFILE="$RUNDIR/filter-$$"

[[ -d $RUNDIR ]] || mkdir -p "$RUNDIR"

trap '
    [[ -e $RULESFILE ]] && rm -f "$RULESFILE"
' EXIT

importrules(){
	bash
}

ARGS=("$@")
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
		-a|--all)
			ALL=1
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

[[ -n $NOFILTERS ]] || FILTERS+=( --filter=": .rsync-filter" )

echo Start snapshot backup

bash "$SDIR/snapshot.sh" "${OPTIONS[@]}" -- "${FILTERS[@]}" "${RSYNCOPTIONS[@]}" "$@"
