#!/usr/bin/env bash
sdir=$(dirname -- "$(readlink -ne -- "$0")")	#full sdir
source "$sdir/functions/all.sh"
port=8760

server="$1"

usage() {
    name=$(basename -s .sh "$0")
    echo Set default server
    echo -e "usage:\n\t $name server-address"
    exit 1
}

[[ -n $server ]] || usage
exists nc && { nc -z $server $port 2>&1 || die server $server not found;}

confdir="$ETCDIR/$server"

[[ -e $confdir/conf.init ]] || bash "$sdir/init.sh" "$server" || die "Can't set conf.init"

default="$(dirname -- "$confdir")/default"

ln -svrfT "$confdir" "$default"

