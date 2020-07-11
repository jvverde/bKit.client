#!/usr/bin/env bash
#compute RVID -- Remote Volume ID
_issourced(){
	[[ "${BASH_SOURCE[0]}" != "${0}" ]]
}

_export_rvid(){
	declare -r rviddir="$(dirname -- "$(readlink -ne -- "${BASH_SOURCE[0]:-$0}")")"
	source "$rviddir/functions/all.sh"
	
	declare -r src="$(readlink -nm -- "$1")"
	IFS='|' read -r volumename volumeserialnumber filesystem drivetype <<<$("$rviddir/drive.sh" "$src")
	exists cygpath && declare drive="$(cygpath -w "$src")" && drive="${drive%%:*}"                      #remove anything after : (if any)
	export BKIT_DRIVE="${drive:-_}"
	export BKIT_VOLUMESERIALNUMBER="${volumeserialnumber:-_}"
	export BKIT_VOLUMENAME="${volumename:-_}"
	export BKIT_DRIVETYPE="${drivetype:-_}"
	export BKIT_FILESYSTEM="${filesystem:-_}"
	export BKIT_RVID="$BKIT_DRIVE.$BKIT_VOLUMESERIALNUMBER.$BKIT_VOLUMENAME.$BKIT_DRIVETYPE.$BKIT_FILESYSTEM"
}

${__SOURCED__:+return} #Intended for shellspec tests

_export_rvid "${1:-.}"

_issourced || echo $BKIT_RVID
