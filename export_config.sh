#!/usr/bin/env bash

usage_export_config() {
	local name="$(basename -- "$0")"
	echo "Set BKIT_CONFIG to point to a given server. Init it if needed"
	echo -e "Usage:\n\t source $name"
	exit 1
}

export_config(){
	source "$(dirname -- "$(readlink -ne -- "${BASH_SOURCE[0]}")")/functions/all.sh"

	[[ -z $1 ]] && usage_export_config

	local server="$1"
	local port=8760

	exists nc && { nc -z $server $port 2>&1   || die "Server '$server' not found";}

	[[ ${ETCDIR+isset} == isset ]] || die "ETCDIR variable not defined"

	local config="$ETCDIR/$server/conf.init"

	[[ -e $config ]] || bash "$sdir/init.sh" "$server"
	[[ -e $config ]] || die "Can't find file $config"
	export BKIT_CONFIG="$config"
}
export_config "$@"
