#!/usr/bin/env bash
#Generate ssh keys and openssl keys
SDIR=$(dirname -- "$(readlink -fn -- "$0")")	#Full SDIR
source "$SDIR/functions/all.sh"

pushd "$SDIR" >/dev/null

usage() {
        echo -e "$@"
        NAME=$(basename -s .sh "$0")
        echo -e "Usage:\n\t $NAME [-n|--new] servername"
        exit 1
}
while [[ $1 =~ ^- ]]
do
        KEY="$1" && shift
        case "$KEY" in
                -h|--help)
                        usage
                ;;
                -n|--new)
                	NEW=new
                ;;
                *)
			usage wrong options $KEY
                ;;
        esac
done

[[ -n $1 ]] || usage "Servername missing"

CONFDIR="${2:-"$ETCDIR/$1"}"
PRIV="$CONFDIR/.priv"
PUB="$CONFDIR/pub"
echo $PRIV
mkdir -pv "$PRIV"
chmod 700 "$PRIV"
mkdir -pv "$PUB"

KEYSSH="$PRIV/ssh.key"
PUBSSH="$PUB/ssh-client.pub"

[[ -e $KEYSSH && -n $NEW ]] && rm "$KEYSSH"

[[ -e $KEYSSH ]] || ssh-keygen -b 256 -t ecdsa -f "$KEYSSH" -q -N "" -C "key from $BKITUSER@$(hostname -f) to $1"
chmod 600 "$PRIV"/*

ssh-keygen -f "$KEYSSH" -y > "$PUBSSH"

#rsync -aiv "$KEYSSH.pub" "$PUBSSH" >&2

{
	openssl ecparam -name secp256k1 -genkey -noout -out "$PRIV/key.pem" || { echo "Fail to generate key" && exit 1; }
	openssl ec -in "$PRIV/key.pem" -pubout -out "$PUB/client.pub" || { echo "Fail to get public key" && exit 1; }
#} > /dev/null  2>&1
}
chmod 700 "$ETCDIR" "$CONFDIR" "$PRIV"
chmod 600 "$PRIV"/*
