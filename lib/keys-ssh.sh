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

declare -r priv="${2:-"$ETCDIR/server/$1/.priv/"}"

umask 077

[[ -e $priv ]] || mkdir -pv "$priv"

declare -r keyssh="$priv/ssh.key"

[[ -e $keyssh && -n $new ]] && rm "$keyssh" #rm if exists and new is requested

[[ -e $keyssh ]] || ssh-keygen -t ed25519 -f "$keyssh" -q -N "" -C ""

chmod -R 600 "$priv"

echo Extract public ssh key from private key
ssh-keygen -f "$keyssh" -y
