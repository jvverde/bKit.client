#!/usr/bin/env bash
die(){ echo -e "$@" >&2 && exit 1;}

usage() {
        echo -e "$@"
        NAME=$(basename -s .sh "$0")
        echo -e "Usage:\n\t $NAME keysdir"
        exit 1
}

[[ -n $1 ]] || usage "Directory missing"

CONFDIR="$1"
PRIV="$CONFDIR/.priv/key.pem"
PUB="$CONFDIR/pub/server.pub"

[[ -e $PRIV && -e $PUB ]] || die "Keys are missing"

openssl pkeyutl -derive -inkey "$PRIV" -peerkey "$PUB" -out "$CONFDIR/.priv/pass.bin"
base64 "$CONFDIR/.priv/pass.bin" > "$CONFDIR/.priv/secret"
