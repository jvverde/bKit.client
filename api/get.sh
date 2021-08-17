#!/usr/bin/env bash
declare -r sdir="$(dirname -- "$(readlink -ne -- "$0")")"	#Full sdir
declare -r parent="$(dirname -- "$sdir")"

usage() {
    declare -r name=$(basename "$0")
    echo Login to an account
    echo -e "Usage:\n\t $name [schema://]server[:port]/path"
    exit 1
}

die() {
  echo "$@" && exit 1
}

#declare -r pattern='^([[:alnum:]]+)?(@([[:alnum:]]+)?(:([[:digit:]]+))?)?$'
declare -r pattern='^((https?)://)?([^:/]+)(:([0-9]+))?(/.+)$'

if [[ "${1:+$1}" =~ $pattern ]]
then
  declare sschema=${BASH_REMATCH[2]}
  declare server=${BASH_REMATCH[3]}
  declare port=${BASH_REMATCH[5]}
  declare path=${BASH_REMATCH[6]}
fi

schema=${schema:-http}
port=${port:-8765}

while [[ ${server:+x} != x ]]
do
  read -p "Server: " server
done

while [[ ${path:+x} != x ]]
do
  read -p "Path: " path
done

while [[ ${token:+x} != x ]]
do
  declare token="$(bash "$parent/login.sh" "@${server}:${port}")"
done

curl -s -H "Content-Type: application/json" -X GET "${schema}://${server}:${port}/${path#/}"  -H "Authorization: Bearer ${token}"|jq .

exit