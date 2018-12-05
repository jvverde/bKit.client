#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH

exists() { type "$1" >/dev/null 2>&1;}
die() { echo -e "$@">&2; exit 1; }

SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR
OS=$(uname -o |tr '[:upper:]' '[:lower:]')

RSYNCOPTIONS=()
FMT='--out-format=%i|%n|/%f|%l'
USER="$(id -nu)"
CONFIGDIR="$(readlink -ne -- "$SDIR/conf/$USER/default" || find "$SDIR/conf/$USER" -type d -exec test -e "{}/conf.init" ';' -print -quit)"
CONFIG="$CONFIGDIR/conf.init"
[[ -e $CONFIG ]] && source "$CONFIG"

export RSYNC_PASSWORD="$(<${PASSFILE})" || die "Pass file no found on location '$PASSFILE'"
[[ -n $SSH ]] && export RSYNC_CONNECT_PROG="$SSH"

while [[ $1 =~ ^- ]]
do
	KEY="$1" && shift
	case "$KEY" in
		--out-format=*)
			FMT="$KEY"
		;;
		*)
			die Unknow option $KEY
		;;
	esac
done

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
REMOTEDIR="${DRIVE:-_}.${VOLUMESERIALNUMBER:-_}.${VOLUMENAME:-_}.${DRIVETYPE:-_}.${FILESYSTEM:-_}/@current/data"

SRC="$ROOT/./$STARTDIR"
dorsync "${RSYNCOPTIONS[@]}" \
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
