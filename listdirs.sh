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
    --snap=*)
      snap="${key#*=}"
    ;;
    *)
      options+=( "$key" )
    ;;
  esac
done

declare dir="${1:-.}"
declare -r snapshot="${snap+.snapshots/${snap}}"

[[ ${BKIT_RVID+isset} == isset ]] || {
  dir="$(readlink -ne -- "$dir")"
  source "$sdir/lib/rvid.sh" "$dir" || die "Can't source rvid"
  declare -r root="$(stat -c%m "$dir")"
  [[ -d $dir ]] && dir="$dir/" #This is important for rsync
  dir=${dir#$root}    #remove mount point
  dir=${dir#/}        #remove heading slash if any
}


rsync ${options+"${options[@]}"} --list-only "$BACKUPURL/$BKIT_RVID/${snapshot:-@current}/data/$dir" #| awk '/@GMT/ {print $5}'	#get a list of all snapshots in backup
