#!/usr/bin/env bash
#Get or set (permanently or not) the server
#And also export BKIT_CONFIG when sourced

server_doit(){  
  issourced(){
    [[ "${BASH_SOURCE[0]}" != "${0}" ]]
  }

  getserver(){
    declare -r confile="$1"
    [[ ! -e $confile ]] && echo "'$confile' doesn't exists" >&2 && exit 1
    # export BKIT_CONFIG (if sourced)
    declare -xg BKIT_CONFIG="$confile"
    issourced || {
      source <(grep -P 'SERVER=|BKIT_ACCOUNT=' "$confile")
      [[ ${FULL+x} == x ]] && echo -n "${BKIT_ACCOUNT}@"
      echo "$SERVER"
    }
  }
  declare -r sdir="$(dirname -- "$(readlink -ne -- "${BASH_SOURCE[0]:-$0}")")"

  source "$sdir/lib/functions/all.sh"

  [[ ${ETCDIR+isset} == isset ]] || die "ETCDIR is not defined"

  declare -r CONFDIR="$ETCDIR/server"

  [[ -d $CONFDIR ]] || mkdir -pv "$CONFDIR"

  function usage(){
      local name=$(basename -s .sh "$0")
      echo -e "\n\n"
      ${1:+echo -e "$@" "\n\n"}
      echo "Set/Get default server"
      echo -e "Usage:\n\t $name [-s|-r] [-u user] [address [port]]\n"
      echo -e "\t\t-s set server as permanent"
      echo -e "\t\t-r get current server"
      exit 1
  }

  declare -r default="$CONFDIR/default"
  declare current="$default"
  declare config="$current/conf.init"

  while [[ $1 =~ ^- ]]
  do
    [[ $1 =~ ^--?h(elp)?$ ]] && usage
    [[ $1 =~ ^--?s(ave)?$ ]] && declare -r save=1 #we want to save it permanently
    [[ $1 =~ ^--?u(ser)?$ ]] && declare -xr BKIT_ACCOUNT="$2" && shift
    [[ $1 =~ ^--?f(ull)?$ ]] && declare -r FULL=full
    [[ $1 =~ ^--?r(ead)?$ ]] && declare -r READONLY=readonly
    shift
  done

  [[ ${READONLY+x} == x ]] && getserver "$config" >&$OUT && exit 0

  [[ ${1+isset} == isset || ! -d $current || ! -e $config ]] && { 
  	declare -r server="${1:-localhost}"
  	declare -r port="${2:-8760}"

  	exists nc && { nc -z $server $port 2>&1 || die bKit server not found at $server:$port;}
    [[ ${BKIT_ACCOUNT:+x} == x ]] || {
      declare -ri cnt=$(find "$CONFDIR" -maxdepth 2 -path "$CONFDIR/$server/*" -type d|wc -l)
      if (( cnt == 1 ))
      then
        declare -xr BKIT_ACCOUNT="$(find "$CONFDIR" -maxdepth 2 -path "$CONFDIR/$server/*" -type d -printf "%f\n"|head -n1)"
      else
        usage 'You need to specify a user account'
      fi
    }
  	current="$CONFDIR/$server/${BKIT_ACCOUNT:-$(usage 'User account not specified')}"
    config="$current/conf.init"

  	[[ -e $config ]] || {
      bash "$sdir/handshake.sh" -p "$port" "$server" || die "Can't set conf.init to server $server"
      [[ -e $config ]] || die "Was unable to set a new server '$server' with account '$BKIT_ACCOUNT'"
    }

    #if permanently set the default
    [[ ${save+isset} == isset ]] && ln -srfT "$current" "$default"
  }
  getserver "$config" >&$OUT #The only result to send to stdout

}  >&2 #Send everything to stderr except what is explicit sent to OUT=stdout

exec {OUT}>&1   #OUT=stdout
server_doit "$@"

 