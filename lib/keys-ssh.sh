#!/usr/bin/env bash
#Generate ssh keys keys
declare -r sdir=$(dirname -- "$(readlink -fn -- "$0")")	#Full sdir
[[ ${ETCDIR+isset} == isset ]] || source "$sdir/functions/all.sh"

pushd "$sdir" >/dev/null

usage() {
        echo -e "$@"
        local name=$(basename -s .sh "$0")
        echo -e "Usage:\n\t $name [-n|--new] servername"
        exit 1
}
while [[ $1 =~ ^- ]]
do
        key="$1" && shift
        case "$key" in
                -h|--help)
                        usage
                ;;
                -n|--new)
                	declare -r new=new
                ;;
                *)
			usage wrong options $key
                ;;
        esac
done

[[ -n $1 ]] || usage "Servername missing"

declare -r confdir="${2:-"$ETCDIR/server/$1"}"
declare -r priv="$confdir/.priv"
declare -r pub="$confdir/pub"

umask 077

[[ -e $priv ]] || mkdir -pv "$priv"
[[ -e $pub ]] || mkdir -pv "$pub"

declare -r keyssh="$priv/ssh.key"
declare -r pubssh="$pub/ssh-client.pub"

[[ -e $keyssh && -n $new ]] && rm "$keyssh" #rm if exists and new is requested

[[ -e $keyssh ]] || ssh-keygen -b 256 -t ecdsa -f "$keyssh" -q -N "" -C "key from $BKITUSER@$(hostname -f) to $1"

echo Extract public ssh key from private key
ssh-keygen -f "$keyssh" -y > "$pubssh"
