#!/usr/bin/env bash
declare -r sdir="$(dirname -- "$(readlink -ne -- "$0")")"	#Full sdir
declare -r parent="$(dirname -- "$sdir")"

usage() {
    declare -r name=$(basename "$0")
    echo Login to an account
    echo -e "Usage:\n\t $name server[:port]]"
    exit 1
}

die() {
  echo "$@" && exit 1
}

#declare -r pattern='^([[:alnum:]]+)?(@([[:alnum:]]+)?(:([[:digit:]]+))?)?$'
declare -r pattern='^([^:]+)(:([0-9]+))?$'

if [[ "${1:+$1}" =~ $pattern ]]
then
  declare server=${BASH_REMATCH[1]}
  declare port=${BASH_REMATCH[3]}
fi

port=${port:-8765}

while [[ ${server:+x} != x ]]
do
  read -p "server: " server
done

while [[ ${token:+x} != x ]]
do
  declare token="$(bash "$parent/login.sh" "@${server}:${port}")"
done

curl -s -H "Content-Type: application/json" -X GET "http://${server}:${port}/v1/user/volumes/a/b/c"  -H "Authorization: Bearer ${token}"|jq .

exit