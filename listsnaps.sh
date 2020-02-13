#!/usr/bin/env bash
set -u
sdir="$(dirname -- "$(readlink -ne -- "$0")")"       #Full dir

source "$sdir/ccrsync.sh"

declare -a options=()
while [[ ${1:-} =~ ^- ]]
do
  key="$1" && shift
  case $key in
    --rvid=*)
      BKIT_RVID="${key#*=}"
    ;;
    *)
      options+=( "$key" )
    ;;
  esac
done

[[ ${BKIT_RVID+isset} == isset ]] || source "$sdir/lib/rvid.sh" ${1+"$1"} || die "Can't source rvid"

rsync ${options+"${options[@]}"} --list-only "$BACKUPURL/./$BKIT_RVID/.snapshots/@GMT-*" | awk '/@GMT/ {print $5}'	#get a list of all snapshots in backup
