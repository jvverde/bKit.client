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
BACKUPDIR="$BACKUP-$(date +"%Y-%m-%dT%H-%M-%S")"
while [[ -e $BACKUPDIR ]]
do 
	BACKUPDIR="${BACKUPDIR}_"
done

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
	[[ ${DST: -1} == / ]] || DST="$DST/"

	#Don't try to chown or chgrp if not root or Administrator
	[[ $OS == cygwin ]] && {
	    $(id -G|grep -qE '\b544\b') || OPTIONS+=( "--no-group" "--no-owner" )
	}
	[[ $OS != cygwin && $UID -ne 0 ]] && OPTIONS+=( "--no-group" "--no-owner" )
}

check() {
	DST="$1"
	[[ -n $(find "${DST}$BACKUPDIR" -prune -empty 2>/dev/null) ]] &&
		echo "Nothing to restore" &&
		rm -rf "${DST}$BACKUPDIR" &&
		echo "Removed empty backup dir $BACKUPDIR" ||
		echo "Old files saved on $BACKUPDIR"
}

while [[ $1 =~ ^- ]]
do
	KEY="$1" && shift
	case "$KEY" in
		-s|--snap|--snapshot)
			SNAP=$1 && shift
    ;;
		-d|--dst)
			destination "$1" && shift
    ;;
		-d=*|--dst=*)
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

RESOURCES=("$@")

CONF=$SDIR/conf/conf.init
[[ -f $CONF ]] || die Cannot found configuration file at $CONF
. "$CONF"                                                                     #get configuration parameters


RESULT="$SDIR/run/restore-$$/"
#trap "rm -rf '$RESULT'" EXIT
mkdir -p "$RESULT"

SRCS=()

for RESOURCE in "${RESOURCES[@]}"
do
	if [[ $RESOURCE =~ ^rsync://[^@]+@ ]]
	then
		[[ -z $DST ]] && DST=${RESOURCES[${#RESOURCES[@]}-1]} && unset RESOURCES[${#RESOURCES[@]}-1] #get last argument
		[[ -d $DST ]] || die "You should specify a (existing) destination directory in last argument or using --dst option"
		SRCS+=( "$RESOURCE" )
		#dorsync "$RESOURCE" "$DST"
	else
		exists cygpath && RESOURCE="$(cygpath -u "$RESOURCE")"
		RESOURCE=$(readlink -m "${RESOURCE}")
		DIR=$RESOURCE
		until [[ -d $DIR ]]				#find a existing parent
		do
			DIR=$(dirname "$DIR")
		done

		ROOT=$(stat -c%m "$DIR")

		BASE="${DIR#${ROOT%%/}}"

		ENTRY=${RESOURCE#$DIR}		#Is empty when resource is a existing directory (DIR==RESOURCE)

		IFS='|' read -r VOLUMENAME VOLUMESERIALNUMBER FILESYSTEM DRIVETYPE <<<$("$SDIR/drive.sh" "$ROOT" 2>/dev/null)

		exists cygpath && DRIVE=$(cygpath -w "$ROOT")
		DRIVE=${DRIVE%%:*}
		RVID="${DRIVE:-_}.${VOLUMESERIALNUMBER:-_}.${VOLUMENAME:-_}.${DRIVETYPE:-_}.${FILESYSTEM:-_}"
		BASE=${BASE%%/}		#remove trailing slash if present
		ENTRY=${ENTRY#/}	#remove leading slash if present

		[[ -n $SNAP ]] && { # if we want an older version
			SRC="$BACKUPURL/$RVID/.snapshots/$SNAP/data$BASE/./$ENTRY"
			METASRC="$BACKUPURL/$RVID/.snapshots/$SNAP/metadata$BASE/./$ENTRY"
		} || {							#or last version
			SRC="$BACKUPURL/$RVID/@current/data$BASE/./$ENTRY"
			METASRC="$BACKUPURL/$RVID/@current/metadata$BASE/./$ENTRY"
		}

		if [[ -n $DST ]]
		then
			SRCS+=( "$SRC" ) #In case we are importing all srcs to a single locatuion, do it later, all in one single rsync call 
		else
			set -o pipefail
			dorsync "$SRC" "$DIR/" | tee "$RESULT/index" || warn "Problems restoring the $BASE/$ENTRY"
			check "$DIR/"

			[[ $OS == 'cygwin' && $FILESYSTEM == 'NTFS' ]] && (id -G|grep -qE '\b544\b') && (
				METADATADST=$SDIR/cache/metadata/by-volume/${VOLUMESERIALNUMBER:-_}$BASE/
				[[ -d $METADATADST ]] || mkdir -pv "$METADATADST"
				rsync "${RSYNCOPTIONS[@]}" -aizR --inplace "${PERM[@]}" "${PERM[@]}" "$FMT" "$METASRC" "$METADATADST" ||
					warn "Problemas ao recuperar $METADATADST/$BASE/"
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
		fi
	fi
done

[[ -n $DST && ${#SRCS[@]} -gt 0 ]] && {
	dorsync "${SRCS[@]}" "$DST"
	check "$DST"
}
