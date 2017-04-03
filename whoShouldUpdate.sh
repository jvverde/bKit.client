#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH

exists() { type "$1" >/dev/null 2>&1;}
die() { echo -e "$@">&2; exit 1; }

SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR
OS=$(uname -o |tr '[:upper:]' '[:lower:]')

RSYNCOPTIONS=()
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
		*)
			die Unknow	option $KEY
		;;
	esac
done

IFS="
"
BACKUPDIR=( $(readlink -e "$@") )
MOUNT=($(stat -c %m "${BACKUPDIR[@]}"))
for M in "${MOUNT[@]}"
do
	[[ $M == ${MOUNT[0]} ]] || die 'All directories/file must belongs to same logical disk'
done
STARTDIR=(${BACKUPDIR[@]#${MOUNT[0]}})
STARTDIR=(${STARTDIR[@]#/})

IFS='|' read -r VOLUMENAME VOLUMESERIALNUMBER FILESYSTEM DRIVETYPE <<<$("$SDIR/drive.sh" "${MOUNT[0]}")

exists cygpath && DRIVE=$(cygpath -w "${MOUNT[0]}")
DRIVE=${DRIVE%%:*}

RVID="${DRIVE:-_}.${VOLUMESERIALNUMBER:-_}.${VOLUMENAME:-_}.${DRIVETYPE:-_}.${FILESYSTEM:-_}"

CONF="$SDIR/conf/conf.init"
[[ -f $CONF ]] || die Cannot found configuration file at $CONF
source "$CONF"

exists rsync || die Cannot find rsync

dorsync(){
	rsync "$@"
}

#EXC="$SDIR/conf/excludes.txt"
FMT='--out-format=%i|%n|%L|/%f|%l'

export RSYNC_PASSWORD="$(cat "$SDIR/conf/pass.txt")"

ROOT=${MOUNT%%/}
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
	"$BACKUPURL/$RVID/@current/data"
