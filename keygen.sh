#!/usr/bin/env bash
die(){ echo -e "$@" >&2 && exit 1;}

SDIR=$(dirname -- "$(readlink -fn -- "$0")")	#Full SDIR

pushd "$SDIR" >/dev/null
BKIT="$(git rev-parse --show-toplevel)"

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

CONFDIR="$BKIT/scripts/client/conf/$(id -un)/$1"
mkdir -p "$CONFDIR"
NAME="$CONFDIR/key"

[[ -e $NAME && -n $NEW ]] && rm "$NAME"

[[ -e $NAME ]] || ssh-keygen -b 256 -t ecdsa -f "$NAME" -q -N "" -C "key from $(id -un)@$(hostname -f) to $1"

[[ -e "${NAME}.pub" ]] && echo "${NAME}.pub" && exit 0 
exit 1
