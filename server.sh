#!/usr/bin/env bash
SDIR=$(dirname -- "$(readlink -ne -- "$0")")	#Full SDIR
source "$SDIR/lib/functions/all.sh"

usage() {
    name=$(basename -s .sh "$0")
    echo Set default server
    echo -e "usage:\n\t $name server-address"
    exit 1
}

if [[ -z $1 ]] 
then
	basename -- "$(readlink -e -- "$ETCDIR/default")"
else
	server="$1"
	port=8760
	exists nc && { nc -z $server $port 2>&1 || die server $server not found;}

	confdir="$ETCDIR/$server"

	[[ -e $confdir/conf.init ]] || bash "$SDIR/init.sh" "$server" || die "Can't set conf.init to server $server"

	default="$(dirname -- "$confdir")/default"

	ln -svrfT "$confdir" "$default"
fi

