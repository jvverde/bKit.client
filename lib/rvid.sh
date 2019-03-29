#!/usr/bin/env bash
#comput RVID -- Remote Volume ID
sdir="$(dirname -- "$(readlink -ne -- "${BASH_SOURCE[0]}")")"
source "$sdir/functions/all.sh"

export_rvid(){
	IFS='|' read -r volumename volumeserialnumber filesystem drivetype <<<$("$sdir/drive.sh" "$1")
	exists cygpath && drive="$(cygpath -w "$1")"
	local drive="${drive%%:*}"                      #remove anything after : (if any)
	export BKIT_RVID="${drive:-_}.${volumeserialnumber:-_}.${volumename:-_}.${drivetype:-_}.${filesystem:-_}"
}

export_rvid "${1:-.}"

