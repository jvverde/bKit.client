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
    issourced || (
      source "$confile"

      if [[ ${FULL+x} == x ]]
      then
        echo "${BKIT_ACCOUNT}@${SERVER}::${BKITSRV_SECTION}:${BKITSRV_IPORT}:${BKITSRV_BPORT}:${BKITSRV_RPORT}:${BKITSRV_UPORT}:${BKITSRV_APORT}"
      elif [[ ${ACCOUNTS+x} == x ]]
      then
        echo "${BKIT_ACCOUNT}@${SERVER}"
      else
        echo "$SERVER"
      fi
    )
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
      echo -e "Usage:\n\t $name [-s|-r] [-f] [-u USER] [address [port]]\n"
      echo -e "Or\n\t $name --delete -u USER address\n"
      echo -e "\t\t-s, --save\t\tset server as permanent"
      echo -e "\t\t-r, --read\t\t get current server"
      echo -e "\t\t-a, --accounts\t\t show account in form user@server"
      echo -e "\t\t-u, --user USER\t\t use USER account. Default to server account user if only one"
      echo -e "\t\t-f, --full\t\t show full account description"
      exit 1
  }

  declare -r default="$CONFDIR/default"
  declare current="$default"
  declare config="$current/conf.init"

  while [[ $1 =~ ^- ]]
  do
    [[ $1 =~ ^--?h(elp)?$ ]] && usage
    [[ $1 == --no-ask ]] && declare -rx BKIT_NOASK=noask
    [[ $1 == --init ]] && declare -r FORCE=force
    [[ $1 =~ ^--?s(ave)?$ ]] && declare -r save=1 #we want to save it permanently
    [[ $1 =~ ^--?u(ser)?$ ]] && declare -xr BKIT_USERNAME="$2" && shift
    [[ $1 =~ ^--?f(ull)?$ ]] && declare -r FULL=full
    [[ $1 =~ ^--?r(ead)?$ ]] && declare -r READONLY=readonly
    [[ $1 =~ ^--?a(ccounts)?$ ]] && declare -r ACCOUNTS=acounts
    [[ $1 == --delete ]] && declare -r DELETE=delete
    shift
  done

  [[ ${READONLY+x} == x ]] && getserver "$config" >&$OUT && exit 0

  [[ ${DELETE+x} == x && ${BKIT_USERNAME+x} == x && ${1+x} == x ]] && {
    config="$CONFDIR/$1/$BKIT_USERNAME/conf.init"
    [[ -e $config ]] && rm -v "$config"
    exit 0
  }

  [[ ${1+isset} == isset || ! -d $current || ! -e $config ]] && {
  	declare -r server="${1:-localhost}"
  	declare -r port="${2:-8760}"

  	exists nc && { nc -z $server $port 2>&1 || die bKit server not found at $server:$port;}
    [[ ${BKIT_USERNAME:+x} == x ]] || {
      declare -ri cnt=$(find "$CONFDIR" -maxdepth 2 -path "$CONFDIR/$server/*" -type d|wc -l)
      if (( cnt == 1 ))
      then
        declare -xr BKIT_USERNAME="$(find "$CONFDIR" -maxdepth 2 -path "$CONFDIR/$server/*" -type d -printf "%f\n"|head -n1)"
      else
        usage 'You need to specify a user account'
      fi
    }
  	current="$CONFDIR/$server/${BKIT_USERNAME:-$(usage 'User account not specified')}"
    config="$current/conf.init"

    [[ ${FORCE+x} == x || ! -e $config ]] && {
      [[ ${BKIT_PASSWORD+x} == x ]] && echo export BKIT_PASSWORD && export BKIT_PASSWORD
      bash "$sdir/handshake.sh" -p "$port" "$server" || die "Can't set conf.init to server $server"
      [[ -e $config ]] || die "Was unable to set a new server '$server' with account '$BKIT_USERNAME'"
    }

    #if permanently set the default
    [[ ${save+isset} == isset && $OS == cygwin ]] && {
      declare -r target="$(cygpath -w "$current")"
      declare -r linkparent="$(cygpath -w "${default%/default}")"
      [[ -e $default ]] && unlink "$default"
      cmd.exe /c mklink /J "$linkparent\\default" "$target"
    }
    [[ ${save+isset} == isset && $OS != cygwin ]] && ln -srfTv "$current" "$default"
  }
  getserver "$config" >&$OUT #The only result to send to stdout

}  >&2 #Send everything to stderr except what is explicit sent to OUT=stdout

exec {OUT}>&1   #OUT=stdout
server_doit "$@"