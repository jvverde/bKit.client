#!/usr/bin/env bash
sdir="$(dirname -- "$(readlink -ne -- "$0")")"
source "$sdir/lib/functions/all.sh"

server="${1:?Usage $0 servername [port]}"
port=${2:-25}
echo Contacting the server ... please wait!
exists nc && {
    nc -z $server $port || die Server $server not found
} || die netcat is not installed
echo ok
