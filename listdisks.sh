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
  case "$key" in
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

rsync ${options+"${options[@]}"} --list-only "$BACKUPURL/./"	| grep -P '^d.+' | grep -Po '.([.][^.]+){4}' #get a list of all snapshots in backup
