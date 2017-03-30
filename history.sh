#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"       #Full DIR

exists() { type "$1" >/dev/null 2>&1;}
die() { echo -e "$@" >&2; exit 1;}
warn() { echo -e "$@" >&2;}

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
			die Unknown	option $KEY
		;;
	esac
done

RESTOREDIR=("$@")

ORIGINALDIR=( "${RESTOREDIR[@]}" )

OLDIFS=$IFS
IFS="
"
exists cygpath && RESTOREDIR=( $(cygpath -u "${ORIGINALDIR[@]}") ) && ORIGINALDIR=( $(cygpath -w "${RESTOREDIR[@]}") )

RESTOREDIR=( $(readlink -m "${RESTOREDIR[@]}") )

IFS=$OLDIFS

CONF=$SDIR/conf/conf.init
[[ -f $CONF ]] || die Cannot found configuration file at $CONF
. "$CONF"                                                                     #get configuration parameters

export RSYNC_PASSWORD="$(cat "$SDIR/conf/pass.txt")"

FMT='--out-format=%o|%i|%b|%l|%M|%t|%f'
PERM=(--acls --owner --group --super --numeric-ids)
BACKUP=".bkit-before-restore-on"
OPTIONS=(
	--archive
	--no-recursive
	--dirs
	--hard-links
	--human-readable
	--relative
	--dry-run
)

for DIR in ${RESTOREDIR[@]}
do
	ENTRY=${RESTOREDIR[$I]#$DIR}
	IFS='|' read -r VOLUMENAME VOLUMESERIALNUMBER FILESYSTEM DRIVETYPE <<<$("$SDIR/drive.sh" "$DIR" 2>/dev/null)

	exists cygpath && DRIVE=$(cygpath -w "$DIR")
	DRIVE=${DRIVE%%:*}
	RVID="${DRIVE:-_}.${VOLUMESERIALNUMBER:-_}.${VOLUMENAME:-_}.${DRIVETYPE:-_}.${FILESYSTEM:-_}"
	ROOT=$(stat -c%m "$DIR")
	DST=$(dirname "$DIR")
	DST=${DST%%/} #remove trailing slash if present
	DIR=${DIR#$ROOT}
	SRC="$BACKUPURL/$RVID/.snapshots/*/data$DIR"
	rsync "${RSYNCOPTIONS[@]}" "${PERM[@]}" "$FMT" "${OPTIONS[@]}" "$SRC" "$DST/" | fgrep "/data$DIR"
done
