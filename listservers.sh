#!/usr/bin/env bash
declare -r sdir="$(dirname -- "$(readlink -ne -- "${BASH_SOURCE[0]:-$0}")")"

function usage(){
    local name=$(basename -s .sh "$0")
    echo "List bkit servers"
    echo -e "Usage:\n\t $name"
    exit 1
}

[[ $1 =~ ^--?h ]] && usage
[[ $1 =~ ^--?f(ull)?$ ]] && declare -r FULL=readonly && shift
[[ $1 =~ ^--?a(ccounts)?$ ]] && declare -r ACCOUNTS=acounts && shift

source "$sdir/lib/functions/all.sh" >&2

[[ ${ETCDIR+isset} == isset ]] || die "ETCDIR is not defined"

declare -r CONFDIR="$ETCDIR/server"

find "$CONFDIR" -type f -name "conf.init"|
while read conffile
do
  unset SERVER
  source "$conffile"
  if [[ ${FULL+x} == x ]]
  then
    echo "${BKIT_ACCOUNT}@${SERVER}::${BKITSRV_SECTION}:${BKITSRV_IPORT}:${BKITSRV_BPORT}:${BKITSRV_RPORT}:${BKITSRV_UPORT}:${BKITSRV_APORT}:${BKITSRV_SPORT}"
  elif [[ ${ACCOUNTS+x} == x ]]
  then
    echo "${BKIT_ACCOUNT}@${SERVER}"
  else
    echo "$SERVER"
  fi
done |sed /^$/d | sort -u
