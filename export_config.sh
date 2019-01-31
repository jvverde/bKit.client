#!/usr/bin/env bash
sdir="$(dirname -- "$(readlink -ne -- "$0")")"
source "$sdir/functions/all.sh"


_usage() {
        local name="$(basename -- "$0")"
        echo "Set BKIT_CONFIG to point to a given server. Init it if needed"
        echo -e "Usage:\n\t source $name"
        exit 1
}

[[ -z $1 ]] && _usage

server="$1"
port=8760

exists nc && { nc -z $server $port 2>&1   || die "Server '$server' not found";}

config="$ETCDIR/$server/conf.init"

[[ -e $config ]] || bash "$sdir/init.sh" "$server"
[[ -e $config ]] || die "Can't find file $config"
export BKIT_CONFIG="$config"
