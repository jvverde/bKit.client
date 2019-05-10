#!/usr/bin/env bash
#comput RVID -- Remote Volume ID
issourced(){
	[[ "${BASH_SOURCE[0]}" != "${0}" ]]
}
sdir="$(dirname -- "$(readlink -ne -- "${BASH_SOURCE[0]:-$0}")")"
source "$sdir/functions/all.sh"

export_rvid(){
	IFS='|' read -r volumename volumeserialnumber filesystem drivetype <<<$("$sdir/drive.sh" "$1")
	exists cygpath && declare drive="$(cygpath -w "$1")" && drive="${drive%%:*}"                      #remove anything after : (if any)
	export BKIT_RVID="${drive:-_}.${volumeserialnumber:-_}.${volumename:-_}.${drivetype:-_}.${filesystem:-_}"
	issourced || echo $BKIT_RVID
}

export_rvid "${1:-.}"

