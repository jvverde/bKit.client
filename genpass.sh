#!/usr/bin/env bash
#Generate password using Diffie-Helman algorithm
SDIR=$(dirname -- "$(readlink -fn -- "$0")")	#Full SDIR
source "$SDIR/functions/all.sh"

usage() {
        echo -e "$@"
        NAME=$(basename -s .sh "$0")
        echo -e "Usage:\n\t $NAME keysdir"
        exit 1
}

[[ -n $1 ]] || usage "Directory missing"

CONFDIR="${1:-$ETCDIR/default}"
PRIV="$CONFDIR/.priv/key.pem"
PUB="$CONFDIR/pub/server.pub"
PASS="$CONFDIR/.priv/pass.bin"
SECRET="$CONFDIR/.priv/secret"


[[ -e $PRIV && -e $PUB ]] || die "Keys are missing"

openssl pkeyutl -derive -inkey "$PRIV" -peerkey "$PUB" -out "$PASS"
base64 "$PASS" > "$SECRET"
chmod 600 "$SECRET" "$PASS"
