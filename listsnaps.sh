#!/usr/bin/env bash
sdir="$(dirname -- "$(readlink -ne -- "$0")")"       #Full dir

source "$sdir/ccrsync.sh"

declare -a options=()
while [[ $1 =~ ^- ]]
do
        key="$1" && shift
        options+=("$key")
done

[[ ${BKIT_RVID+isset} == isset ]] || {
	dir="${1:-$(pwd)}"
	IFS='|' read -r volumename volumeserialnumber filesystem drivetype <<<$("$sdir/drive.sh" "$dir" 2>/dev/null)
	exists cygpath && drive=$(cygpath -w "$dir")
	drive=${drive%%:*}
	BKIT_RVID="${drive:-_}.${volumeserialnumber:-_}.${volumename:-_}.${drivetype:-_}.${filesystem:-_}"
}

rsync "${options[@]}" --list-only "$BACKUPURL/./$BKIT_RVID/.snapshots/" | awk '/@GMT/ {print $5}'	#get a list of all snapshots in backup
