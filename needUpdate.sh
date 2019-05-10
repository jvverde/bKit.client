#!/usr/bin/env bash
#Checks who needs to be backup
SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR

FMT='--out-format=%i|%n|/%f|%l'

source "$SDIR/ccrsync.sh"

declare -a OPTIONS=()
declare snap='@current'

while [[ $1 =~ ^- ]]
do
	KEY="$1" && shift
	case "$KEY" in
		--out-format=*)
			FMT="$KEY"
		;;
		--snap=*)
			snap="${KEY#*=}"
		;;
		--cmptarget=*)
			CMPTARGET="${KEY#*=}"
		;;
		*)
			OPTIONS+=( "$KEY" )
		;;
	esac
done

[[ -e $1 ]] || die "'$1' doesn't exist"
 
true ${CMPTARGET:='data'}		#by default we check data, but we can also check metadata or anything else. Export CMPTARGET before invoke me

dorsync(){
	rsync "$@"
}

BACKUPDIR="$(readlink -ne "$1")"

ROOT="$(stat -c %m "$BACKUPDIR")"
STARTDIR="${BACKUPDIR#$ROOT}"		#remove mount point from path
STARTDIR="${STARTDIR#/}" 		#remove leading slash if any
ROOT=${ROOT%/} 				#remove trailing slash if any

[[ ${BKIT_RVID+isset} == isset ]] || {
	IFS='|' read -r VOLUMENAME VOLUMESERIALNUMBER FILESYSTEM DRIVETYPE <<<$("$SDIR/lib/drive.sh" "$ROOT")
	exists cygpath && DRIVE=$(cygpath -w "$ROOT")
	DRIVE=${DRIVE%%:*}			#remove anything after : (if any)
	#compute Remote Volume ID
  	BKIT_RVID="${DRIVE:-_}.${VOLUMESERIALNUMBER:-_}.${VOLUMENAME:-_}.${DRIVETYPE:-_}.${FILESYSTEM:-_}"
}

REMOTEDIR="$BKIT_RVID/$snap/$CMPTARGET"

SRC="$ROOT/./$STARTDIR"
dorsync "${RSYNCOPTIONS[@]}" \
	"${OPTIONS[@]}" \
	--dry-run \
	--recursive \
	--links \
	--delete-before \
	--times \
	--hard-links \
	--relative \
	--itemize-changes \
	$FMT \
	"$SRC" \
	"$BACKUPURL/$REMOTEDIR"
