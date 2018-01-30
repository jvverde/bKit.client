#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH

exists() { type "$1" >/dev/null 2>&1;}
die() { echo -e "$@">&2; exit 1; }

SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR
OS=$(uname -o |tr '[:upper:]' '[:lower:]')

RSYNCOPTIONS=()
FMT='--out-format=%i|%n|/%f|%l'

while [[ $1 =~ ^- ]]
do
	KEY="$1" && shift
	case "$KEY" in
		-- )
			while [[ $1 =~ ^- ]]
			do
				RSYNCOPTIONS+=("$1")
				shift
			done
		;;
		--root=*)
			ROOT=$(readlink -e "${KEY#*=}")
		;;
		--out-format=*)
			FMT="$KEY"
		;;
		--remotedir=*)
			REMOTEDIR="${KEY#*=}"
		;;
		*)
			die Unknow	option $KEY
		;;
	esac
done

IFS="
"
BACKUPDIR=( $(readlink -e "$@") )

[[ -n $ROOT ]] || {
	MOUNT=($(stat -c %m "${BACKUPDIR[@]}"))
	ROOT=${MOUNT[0]}
	for M in "${MOUNT[@]}"
	do
		[[ $M == $ROOT ]] || die 'All directories/file must belongs to same logical disk'
	done
}

STARTDIR=("${BACKUPDIR[@]#$ROOT}") #remove mount pointfrom path
STARTDIR=("${STARTDIR[@]#/}") #remove leading slash if any

[[ ${#STARTDIR[@]} -eq 0 ]] && STARTDIR=("")

[[ -n $REMOTEDIR ]] || {
	IFS='|' read -r VOLUMENAME VOLUMESERIALNUMBER FILESYSTEM DRIVETYPE <<<$("$SDIR/drive.sh" "$ROOT")

	exists cygpath && DRIVE=$(cygpath -w "$ROOT")
	DRIVE=${DRIVE%%:*}
	REMOTEDIR="${DRIVE:-_}.${VOLUMESERIALNUMBER:-_}.${VOLUMENAME:-_}.${DRIVETYPE:-_}.${FILESYSTEM:-_}/@current/data"
}

CONF="$SDIR/conf/conf.init"
[[ -f $CONF ]] || die Cannot found configuration file at $CONF
source "$CONF"

exists rsync || die Cannot find rsync

dorsync(){
	rsync "$@"
}

#EXC="$SDIR/conf/excludes.txt"

export RSYNC_PASSWORD="$(cat "$SDIR/conf/pass.txt")"

ROOT=${ROOT%%/} #remove trailing slash if any

SRCS=()
for DIR in "${STARTDIR[@]}"
do
	SRCS+=("$ROOT/./$DIR")
done

dorsync "${RSYNCOPTIONS[@]}" \
	--dry-run \
	--one-file-system \
	--recursive \
	--links \
	--times \
	--hard-links \
	--relative \
	--itemize-changes \
	$FMT \
	"${SRCS[@]}" \
	"$BACKUPURL/$REMOTEDIR"
