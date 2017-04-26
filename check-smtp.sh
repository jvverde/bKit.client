#!/bin/bash

die() { echo -e "$@">&2; exit 1; }
exists() { type "$1" >/dev/null 2>&1;}

SERVER=$1
PORT=${2:-25}
echo Contacting the server ... please wait!
exists nc && {
    nc -z $SERVER $PORT || die Server $SERVER not found
}
