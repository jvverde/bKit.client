#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
OS=$(uname -o |tr '[:upper:]' '[:lower:]')
SDIR="$(dirname "$(readlink -f "$0")")"
exists() { type "$1" >/dev/null 2>&1;}
die() { echo -e "$@">&2; exit 1; }
usage() {
	NAME=$(basename -s .sh "$0")
	echo Backup one or more directories or files
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

RUNDIR=$SDIR/run
[[ -d $RUNDIR ]] || mkdir -p $RUNDIR

EXCL=$RUNDIR/exclude-$$.lst
:> "$EXCL"

EXCLUDESDIR="$SDIR/excludes"
EXCLUDESALL="$EXCLUDESDIR/excludes-all.txt"
[[ -e $EXCLUDESALL ]] && cat "$EXCLUDESALL" >> "$EXCL"
[[ $OS == cygwin ]] && {
	bash "$SDIR/tools/hklm.sh"| bash "$SDIR/tools/w2f.sh" >> "$EXCL"

}

bash "$SDIR/backup.sh" "${OPTIONS[@]}" -- --filter=". $EXCL" --filter=": .rsync-filter" "${RSYNCOPTIONS[@]}" "$@"
