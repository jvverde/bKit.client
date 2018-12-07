#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH

exists() { type "$1" >/dev/null 2>&1;}
die() { echo -e "$@">&2; exit 1; }

SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR
OS=$(uname -o |tr '[:upper:]' '[:lower:]')

FMT='--out-format=%i|%n|/%f|%l'

source "$SDIR/ccrsync.sh"

OPTIONS=()
while [[ $1 =~ ^- ]]
do
	KEY="$1" && shift
	case "$KEY" in
		--out-format=*)
			FMT="$KEY"
		;;
		--cmptarget=*)
			CMPTARGET="${KEY#*=}"
		;;
		*)
			OPTIONS+=( "$KEY" )
		;;
	esac
done

true ${CMPTARGET:='data'}		#by default we check data, but we can also check metadata or anything else. Export CMPTARGET before invoke me

dorsync(){
	rsync "$@"
}

BACKUPDIR="$(readlink -ne "$1")"

ROOT="$(stat -c %m "$BACKUPDIR")"
STARTDIR="${BACKUPDIR#$ROOT}"		#remove mount point from path
STARTDIR="${STARTDIR#/}" 		#remove leading slash if any
ROOT=${ROOT%/} 				#remove trailing slash if any

IFS='|' read -r VOLUMENAME VOLUMESERIALNUMBER FILESYSTEM DRIVETYPE <<<$("$SDIR/drive.sh" "$ROOT")

exists cygpath && DRIVE=$(cygpath -w "$ROOT")
DRIVE=${DRIVE%%:*}			#remove anything after : (if any)
REMOTEDIR="${DRIVE:-_}.${VOLUMESERIALNUMBER:-_}.${VOLUMENAME:-_}.${DRIVETYPE:-_}.${FILESYSTEM:-_}/@current/$CMPTARGET"

SRC="$ROOT/./$STARTDIR"
dorsync "${RSYNCOPTIONS[@]}" \
	"${OPTIONS[@]}" \
	--dry-run \
	--recursive \
	--links \
	--times \
	--hard-links \
	--relative \
	--itemize-changes \
	$FMT \
	"$SRC" \
	"$BACKUPURL/$REMOTEDIR"
