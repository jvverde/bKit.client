#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"       #Full DIR
OS=$(uname -o |tr '[:upper:]' '[:lower:]')

exists() { type "$1" >/dev/null 2>&1;}
die() { echo -e "$@" >&2; exit 1;}
warn() { echo -e "$@" >&2;}

export RSYNC_PASSWORD="$(cat "$SDIR/conf/pass.txt")"

FMT='--out-format=%o|%i|%b|%l|%f|%M|%t'
PERM=(--perms --acls --owner --group --super --numeric-ids)
BACKUP=".bkit-before-restore-on"
BACKUPDIR="$BACKUP-$(date +"%c")"
OPTIONS=(
	--backup
	--backup-dir="$BACKUPDIR"
	--archive
	--exclude="$BACKUP-*"
	--hard-links
	--compress
	--human-readable
	--relative
	--partial
	--partial-dir=".bkit.rsync-partial"
	--delay-updates
	--delete-delay
)

RSYNCOPTIONS=()

dorsync() {
	rsync "${RSYNCOPTIONS[@]}" "${PERM[@]}" "$FMT" "${OPTIONS[@]}" "$@"
}

destination() {
	DST="$1"
	[[ -d $DST ]] || die $DST should be a directory	
	[[ ${DST: -1} == / ]] && DST="$DST./" || DST="$DST/./"
}

while [[ $1 =~ ^- ]]
do
	KEY="$1" && shift
	case "$KEY" in
		-d|--date)
			DATE=$1 && shift
    ;;
		-dst|--destination)
			destination "$1" && shift
    ;;
		-dst=*|--destination=*)
			destination "${KEY#*=}" 
    ;;
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

dorsync() {
	rsync "${RSYNCOPTIONS[@]}" "${PERM[@]}" "$FMT" "${OPTIONS[@]}" "$@"
}

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


RESULT="$SDIR/RUN/restore-$$/"
trap "rm -rf '$RESULT'" EXIT
mkdir -p "$RESULT"

for RESTOREDIR in "${RESTOREDIR[@]}"
do
	DIR=$RESTOREDIR
	until [[ -d $DIR ]]
	do
		DIR=$(dirname "$DIR")
	done

	ROOT=$(stat -c%m "$DIR")

	BASE="${DIR#${ROOT%%/}}"

	ENTRY=${RESTOREDIR#$DIR}
	IFS='|' read -r VOLUMENAME VOLUMESERIALNUMBER FILESYSTEM DRIVETYPE <<<$("$SDIR/drive.sh" "$ROOT" 2>/dev/null)

	exists cygpath && DRIVE=$(cygpath -w "$ROOT")
	DRIVE=${DRIVE%%:*}
	RVID="${DRIVE:-_}.${VOLUMESERIALNUMBER:-_}.${VOLUMENAME:-_}.${DRIVETYPE:-_}.${FILESYSTEM:-_}"
	BASE=${BASE%%/}		#remove trailing slash if present
	ENTRY=${ENTRY#/}	#remove leading slash if present
	[[ -n $DATE ]] && { # a older version
		SRC="$BACKUPURL/$RVID/.snapshots/$DATE/data$BASE/./$ENTRY"
		METASRC="$BACKUPURL/$RVID/.snapshots/$DATE/metadata$BASE/./$ENTRY"
	} || {							#or last version
		SRC="$BACKUPURL/$RVID/@current/data$BASE/./$ENTRY"
		METASRC="$BACKUPURL/$RVID/@current/metadata$BASE/./$ENTRY"
	}
	set -o pipefail
	[[ -z $DST ]] && DST="$DIR/"
	dorsync "$SRC" "$DST" | tee "$RESULT/index" || warn "Problems restoring the $BASE/$ENTRY"
	[[ -n $(find "$RESTOREDIR/$BACKUPDIR" -prune -empty 2>/dev/null) ]] && rm -rfv "$RESTOREDIR/$BACKUPDIR"

	[[ $OS == 'cygwin' && $FILESYSTEM == 'NTFS' ]] && (id -G|grep -qE '\b544\b') && (
		METADATADST=$SDIR/cache/metadata/by-volume/${VOLUMESERIALNUMBER:-_}$BASE/
		[[ -d $METADATADST ]] || mkdir -pv "$METADATADST"
		rsync "${RSYNCOPTIONS[@]}" -aizR --inplace "${PERM[@]}" "${PERM[@]}" "$FMT" "$METASRC" "$METADATADST" || warn "Problemas ao recuperar $METADATADST/$BASE/"
		DRIVE=$(cygpath -w "$ROOT")
		: > "$RESULT/acls"
		cat "$RESULT/index"|grep 'recv[|][.>]f'|cut -d'|' -f5|
		while read FILE
		do
			ACLFILE=$(dirname "$METADATADST$FILE")/.bkit-acls
			echo $ACLFILE
			iconv -f UTF-16LE -t UTF-8 "$ACLFILE" |
				sed -E 's#^\+File [A-Z]:#+File '${DRIVE:0:1}':#i' |
				iconv  -f UTF-8 -t UTF-16LE >> "$RESULT/acls"
			cat
		done
		[[ -s "$RESULT/acls" ]] && {
			echo 'Apply ACLS now'
			bash "$SDIR/applyacls.sh" "$RESULT/acls"
		}
	)

done
