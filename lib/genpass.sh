#!/usr/bin/env bash
#Generate password using Diffie-Helman algorithm
set -u
sdir=$(dirname -- "$(readlink -fn -- "$0")")	#Full sdir
source "$sdir/functions/all.sh"

usage() {
        echo -e "$@"
        local name="$(basename -- "$0")"
        echo -e "Usage:\n\t $name confdir"
        exit 1
}

[[ ${1:-} =~ ^--?h ]] && usage "Directory missing"

confdir="${1:-$ETCDIR/default}"
priv="$confdir/.priv/key.pem"
pub="$confdir/pub/server.pub"
pass="$confdir/.priv/pass.bin"
secret="$confdir/.priv/secret"


[[ -e $priv && -e $pub ]] || die "Keys are missing"

openssl pkeyutl -derive -inkey "$priv" -peerkey "$pub" -out "$pass"
base64 "$pass" > "$secret"
chmod 600 "$secret" "$pass"