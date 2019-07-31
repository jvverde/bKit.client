#!/usr/bin/env bash
#Checks who needs to be backup
set -u
sdir="$(dirname "$(readlink -f "$0")")"				#Full DIR

source "$sdir/ccrsync.sh"

declare -a options=()
declare snap='@current'

declare fmt="--out-format=%i|%n|/%f|%l"

true ${1:? "Usage: $0 [options] src"}

while [[ ${1:? "Usage: $0 [options] src"} =~ ^- ]]
do
	key="$1" && shift
	case "$key" in
		--out-format=*)
			fmt="$key"
		;;
		--snap=*)
			snap="${key#*=}"
		;;
		--BKIT_TARGET=*)
			BKIT_TARGET="${key#*=}"
		;;
		*)
			options+=( "$key" )
		;;
	esac
done

[[ -e $1 ]] || die "'$1' doesn't exist"
 
true ${BKIT_TARGET:='data'}		#by default we check data, but we can also check metadata or anything else. Export BKIT_TARGET before invoke me

dorsync(){
	rsync "$@"
}

backupdir="$(readlink -ne "$1")"

mnt="${BKIT_MNTPOINT:-"$(stat -c %m "$backupdir")"}"
startdir="${backupdir#$mnt}"		#remove mount point from path
startdir="${startdir#/}" 		#remove leading slash if any
mnt=${mnt%/} 				#remove trailing slash if any

[[ ${BKIT_RVID+isset} == isset ]] || source "$sdir/lib/rvid.sh" || die "Can't source rvid"

remotedir="$BKIT_RVID/$snap/$BKIT_TARGET"

src="$mnt/./$startdir"

dorsync "${RSYNCOPTIONS[@]}" \
	${options+"${options[@]}"} \
	--dry-run \
	--recursive \
	--links \
	--delete-before \
	--times \
	--hard-links \
	--relative \
	--itemize-changes \
	$fmt \
	"$src" \
	"$BACKUPURL/$remotedir"
