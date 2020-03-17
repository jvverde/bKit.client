#!/usr/bin/env bash
set -u
sdir="$(dirname -- "$(readlink -ne -- "$0")")"       #Full dir

source "$sdir/lib/functions/all.sh"

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
    --snap=*)
      snap="${key#*=}"
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

exists cygpath && declare dir="$(cygpath -u "${1:-.}")" || declare dir="${1:-.}"

declare -r snapshot="${snap+.snapshots/${snap}}"

source "$sdir/ccrsync.sh"


[[ ${BKIT_RVID+isset} == isset ]] || {
  dir="$(readlink -nm -- "$dir")"
  declare parent="$dir"
  while [[ ! -e $parent && -n $parent ]]
  do
    parent="$(dirname -- $parent)"
  done
  source "$sdir/lib/rvid.sh" "$parent" || die "Can't source rvid"
  declare -r root="$(stat -c%m "$parent")"
  # If is a directory or if filename not exist => assume it is a directory <= This is a listdir not a listfile
  [[ -d $dir || ! -e $dir ]] && dir="$dir/" #This is important for rsync
  dir=${dir#$root}    #remove mount point
  dir=${dir#/}        #remove heading slash if any
}


rsync ${options+"${options[@]}"} --list-only "$BACKUPURL/$BKIT_RVID/${snapshot:-@current}/data/$dir" #| awk '/@GMT/ {print $5}'	#get a list of all snapshots in backup
