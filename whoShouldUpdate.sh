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

BACKUPDIR=$(readlink -e "$1")

MOUNT=$(stat -c %m "$BACKUPDIR")
STARTDIR="${BACKUPDIR#$MOUNT}"
STARTDIR="${STARTDIR#/}"


IFS='|' read -r VOLUMENAME VOLUMESERIALNUMBER FILESYSTEM DRIVETYPE <<<$("$SDIR/drive.sh" "$BACKUPDIR" 2>/dev/null)

RVID="${DRIVE:-_}.${VOLUMESERIALNUMBER:-_}.${VOLUMENAME:-_}.${DRIVETYPE:-_}.${FILESYSTEM:-_}"
CONF="$SDIR/conf/conf.init"
[[ -f $CONF ]] || die Cannot found configuration file at $CONF
source "$CONF"

exists rsync || die Cannot find rsync

dorsync(){
	rsync "$@" 2>&1
}

EXC="$SDIR/conf/excludes.txt"
FMT='--out-format=%i|%n|%L|/%f|%l'

export RSYNC_PASSWORD="$(cat "$SDIR/conf/pass.txt")"

dorsync "${RSYNCOPTIONS[@]}" \
	--dry-run \
	--filter=': .rsync-filter' \
	--one-file-system \
	--recursive \
	--links \
	--times \
	--hard-links \
	--relative \
	--itemize-changes \
	--exclude-from="$EXC" \
	$FMT \
	"$MOUNT/./$STARTDIR" \
	"$BACKUPURL/$RVID/@current/data"
