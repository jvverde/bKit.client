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

PERM=(--acls --owner --group --super --numeric-ids)
BACKUP=".bkit-before-restore-on"
OPTIONS=(
	--archive
	--hard-links
	--human-readable
	--relative
	--dry-run
)

for DIR in "${RESTOREDIR[@]}"
do
	IFS='|' read -r VOLUMENAME VOLUMESERIALNUMBER FILESYSTEM DRIVETYPE <<<$("$SDIR/drive.sh" "$DIR" 2>/dev/null)

	exists cygpath && DRIVE=$(cygpath -w "$DIR")
	DRIVE=${DRIVE%%:*}
	RVID="${DRIVE:-_}.${VOLUMESERIALNUMBER:-_}.${VOLUMENAME:-_}.${DRIVETYPE:-_}.${FILESYSTEM:-_}"

	DST=$(dirname "$DIR")
	DST=${DST%%/} #remove trailing slash if present

	ROOT=$(stat -c%m "$DIR")

	PARENT=$DIR

	DIR=${DIR#$ROOT}
	DIR=${DIR#/}

	FILTERS=()
	until [[ $PARENT == $ROOT || ${#PARENT} -le 1 ]]
	do
		P=${PARENT#$ROOT}
		F="--include=/${P#/}"
		FILTERS+=( "$F" )
		PARENT=$(dirname "$PARENT")
	done
	FILTERS+=(
		'--exclude=*'
	)

	VERSIONS=( $(rsync --list-only "$BACKUPURL/$RVID/.snapshots/"|grep -Po '@GMT-.+$') )
	for V in "${VERSIONS[@]}"
	do
		FMT="--out-format=$V|%o|%i|%M|%l|%f"
		SRC="$BACKUPURL/$RVID/.snapshots/$V/data/./"
		rsync "${RSYNCOPTIONS[@]}" "${FILTERS[@]}" "${PERM[@]}" "$FMT" "${OPTIONS[@]}" "$SRC" "$ROOT/" |
		awk -F'|' -v entry="$DIR" '$6 == entry {print $0}'
	done | awk -F'|' '
		{
			LINES[$2 $3 $4 $5] = $0
		}
		END{
			for (L in LINES) print LINES[L]
		}
	' | sort
done
