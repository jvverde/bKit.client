#!/usr/bin/env bash
# Checks who needs to be backup
set -u
sdir="$(dirname "$(readlink -f "$0")")"				#Full DIR


set_server () {
  source "$sdir"/server.sh "$1"
}


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
			[[ $snap =~ ^@GMT- ]] && snap=".snapshots/$snap"
		;;
		--BKIT_TARGET=*)
			BKIT_TARGET="${key#*=}"
		;;
		-s|--server)
      set_server "$1" && shift
    ;;
    -s=*|--server=*)
      set_server "${key#*=}"
    ;;
		*)
			options+=( "$key" )
		;;
	esac
done

source "$sdir/ccrsync.sh"

declare -r entry="${1:-.}"

[[ -e $entry ]] || die "'$entry' doesn't exist"
 
true ${BKIT_TARGET:='data'}		#by default we check data, but we can also check metadata or anything else. Export BKIT_TARGET before invoke me

dorsync(){
	stdbuf -i0 -o0 -e0 rsync "$@"
}

backupdir="$(readlink -ne "$entry")"

mnt="${BKIT_MNTPOINT:-"$(stat -c %m "$backupdir")"}"
startdir="${backupdir#$mnt}"		#remove mount point from path
startdir="${startdir#/}" 		#remove leading slash if any
mnt=${mnt%/} 				#remove trailing slash if any

[[ ${BKIT_RVID+isset} == isset ]] || source "$sdir/lib/rvid.sh" "$mnt" || die "Can't source rvid"

remotedir="$BKIT_RVID/$snap/$BKIT_TARGET/"

src="$mnt/./$startdir"

[[ -d $backupdir ]] && src="$src/"

dorsync ${RSYNCOPTIONS[@]+"${RSYNCOPTIONS[@]}"} \
	--recursive \
	--links \
	--times \
	--hard-links \
	--relative \
	${options+"${options[@]}"} \
	--dry-run \
	--itemize-changes \
	$fmt \
	"$src" \
	"$BACKUPURL/$remotedir"
