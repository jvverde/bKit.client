#!/usr/bin/env bash
SDIR="$(dirname -- "$(readlink -ne -- "$0")")"
source "$SDIR/lib/functions/all.sh"

SERVER=$1
PORT=${2:-25}
echo Contacting the server ... please wait!
exists nc && {
    nc -z $SERVER $PORT || die Server $SERVER not found
}
