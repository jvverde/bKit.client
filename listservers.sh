#!/usr/bin/env bash
declare -r sdir="$(dirname -- "$(readlink -ne -- "${BASH_SOURCE[0]:-$0}")")"

function usage(){
    local name=$(basename -s .sh "$0")
    echo "Set/Get default server"
    echo -e "usage:\n\t $name [-s] [address [port]]\n\t\t-s set server as permanent"
    exit 1
}

[[ $1 =~ ^--?h ]] && usage

source "$sdir/lib/functions/all.sh"

[[ ${ETCDIR+isset} == isset ]] || die "ETCDIR is not defined"

declare -r CONFDIR="$ETCDIR/server"

find "$CONFDIR" -mindepth 1 -maxdepth 1 -type d -exec test -e "{}/conf.init" ';' -printf "%f\n" 