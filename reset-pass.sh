#!/usr/bin/env bash
declare -r sdir=$(dirname -- "$(readlink -ne -- "$0")")	#Full sdir
source "$sdir/lib/functions/all.sh"

set -eu

usage() {
    declare -r name=$(basename -s .sh "$0")
    echo Reset password with server
    echo -e "Usage:\n\t $name server" >&2
    exit 1
}

[[ ${1:+x} == x ]] || usage

[[ ${1+"$1"} =~ ^--?h(elp)? ]] && usage

declare -r server="$1"

umask 077

declare -r confdir="$ETCDIR/server/$server"

[[ -d "$confdir" ]] || die "'$confdir' doesn't exists"

declare -r tmp="$confdir/tmp"
declare -r private="$confdir/.priv"
declare -r conffile="$confdir/conf.init"


mkdir -pv "$tmp"
mkdir -pv "$private"

#generate a new private key
openssl ecparam -name secp256k1 -genkey -noout -out "$private/newkey.pem"
chmod 600 "$private/newkey.pem"

#get the new public key 
openssl ec -in "$private/newkey.pem" -pubout -out "$tmp/client.pubkey"

#Sign the new public key with older private key
openssl dgst -sign "$private/key.pem" -out "$tmp/pubkey.sign" "$tmp/client.pubkey"

#prepare to rsync with server
source "$sdir/ccrsync.sh"

declare -r url="${BACKUPURL}#reset"

rsync -rti "$tmp/" "$url/" || die "Exit value of rsync is non null: $?"
rsync -rti "$url/" "$tmp/" || die "Exit value of rsync is non null: $?"

#Compute new secret
openssl pkeyutl -derive -inkey "$private/newkey.pem" -peerkey "$private/server.pubkey" | base64 -w0 > "$private/secret"
chmod 600 "$private/secret"

#Drop old key and store new one 
mv -fTv "$private/newkey.pem" "$private/key.pem"

exit 0