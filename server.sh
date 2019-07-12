#!/usr/bin/env bash
#Get or set (permanently or not) the server
#And also export BKIT_CONFIG when sourced

issourced(){
  [[ "${BASH_SOURCE[0]}" != "${0}" ]]
}
sdir="$(dirname -- "$(readlink -ne -- "${BASH_SOURCE[0]:-$0}")")"

source "$sdir/lib/functions/all.sh"

usage() {
    name=$(basename -s .sh "$0")
    echo Set default server
    echo -e "usage:\n\t $name address port"
    exit 1
}

[[ $1 =~ ^--?h ]] && usage
[[ $1 =~ ^-s ]] && shift && save=1 #we wnat to save it permanently

default="$ETCDIR/default"
current="$default"
config="$current/conf.init"

[[ ${1+isset} == isset || ! -d $current || ! -e $config ]] && { 
	server="${1:-localhost}"
	port="${2:-8760}"

	exists nc && { nc -z $server $port 2>&1 || die Bkit server not found at $server:$port;}

	current="$ETCDIR/$server"
  config="$current/conf.init"

	[[ -e $config ]] || bash "$sdir/init.sh" "$server" || die "Can't set conf.init to server $server"

  #if permanently set de default
  [[ ${save+isset} == isset ]] && ln -srfT "$current" "$default"
}
export BKIT_CONFIG="$config"

issourced || basename -- "$(readlink -e -- "$current")"
