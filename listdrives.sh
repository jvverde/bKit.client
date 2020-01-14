#!/usr/bin/env bash
set -u
sdir="$(dirname -- "$(readlink -ne -- "$0")")"       #Full dir

source "$sdir/ccrsync.sh"

declare -a options=()
while [[ ${1:-} =~ ^- ]]
do
        key="$1" && shift
        options+=( "$key" )
done

rsync ${options+"${options[@]}"} --list-only "$BACKUPURL/./"	| grep -Po '.([.][^.]+){4}' #get a list of all snapshots in backup
