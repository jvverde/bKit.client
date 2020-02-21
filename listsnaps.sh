#!/usr/bin/env bash
set -u
sdir="$(dirname -- "$(readlink -ne -- "$0")")"       #Full dir

set_server () {
  source "$sdir"/server.sh "$1"
}

declare -a options=()
while [[ ${1:-} =~ ^- ]]
do
  key="$1" && shift
  case $key in
    --rvid=*)
      BKIT_RVID="${key#*=}"
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

[[ ${BKIT_RVID+isset} == isset ]] || source "$sdir/lib/rvid.sh" ${1+"$1"} || die "Can't source rvid"

rsync ${options+"${options[@]}"} --list-only "$BACKUPURL/./$BKIT_RVID/.snapshots/@GMT-*" | awk '/@GMT/ {print $5}'	#get a list of all snapshots in backup
