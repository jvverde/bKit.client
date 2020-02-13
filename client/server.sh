#!/usr/bin/env bash
#Get or set (permanently or not) the server
#And also export BKIT_CONFIG when sourced

server_doit(){  
  issourced(){
    [[ "${BASH_SOURCE[0]}" != "${0}" ]]
  }

  declare -r sdir="$(dirname -- "$(readlink -ne -- "${BASH_SOURCE[0]:-$0}")")"

  source "$sdir/lib/functions/all.sh"

  [[ ${ETCDIR+isset} == isset ]] || die "ETCDIR is not defined"

  declare -r CONFDIR="$ETCDIR/server"

  function usage(){
      local name=$(basename -s .sh "$0")
      echo Set default server
      echo -e "usage:\n\t $name address port"
      exit 1
  }

  [[ $1 =~ ^--?h ]] && usage
  [[ $1 =~ ^-s ]] && shift && save=1 #we want to save it permanently

  declare -r default="$CONFDIR/default"
  declare current="$default"
  declare config="$current/conf.init"

  [[ ${1+isset} == isset || ! -d $current || ! -e $config ]] && { 
  	declare -r server="${1:-localhost}"
  	declare -r port="${2:-8760}"

  	exists nc && { nc -z $server $port 2>&1 || die bKit server not found at $server:$port;}

  	current="$CONFDIR/$server"
    config="$current/conf.init"

  	[[ -e $config ]] || bash "$sdir/init.sh" "$server" || die "Can't set conf.init to server $server"

    #if permanently set the default
    [[ ${save+isset} == isset ]] && ln -srfT "$current" "$default"
  }
  export BKIT_CONFIG="$config"

  issourced || basename -- "$(readlink -e -- "$current")"
}

server_doit "$@"
