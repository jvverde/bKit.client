#!/usr/bin/env bash
declare -r sdir=$(dirname -- "$(readlink -ne -- "$0")")	#Full sdir

usage() {
    declare -r name=$(basename "$0")
    echo Login to an account
    echo -e "Usage:\n\t $name [username[@server[:port]]]"
    exit 1
}

die() {
  echo "$@" && exit 1
}

#declare -r pattern='^([[:alnum:]]+)?(@([[:alnum:]]+)?(:([[:digit:]]+))?)?$'
declare -r pattern='^([[:alnum:]]*)(@([^:]+)(:([0-9]+))?)?$'

if [[ "${1:+$1}" =~ $pattern ]]
then
  declare username=${BASH_REMATCH[1]}
  declare server=${BASH_REMATCH[3]}
  declare port=${BASH_REMATCH[5]}
fi

port=${port:-8765}
while [[ ${username:+x} != x ]]
do
  read -p "User: " username
done

declare -r hashpass="$(
  openssl dgst -sha512 -hex -r < <(
    while [[ ${bkitpass:+x} != x ]]
    do
      read -sp "Password for user $username: " bkitpass
    done
    echo -n "$bkitpass"
  ) | awk '{print $1}'
)"

echo -n

while [[ ${server:+x} != x ]]
do
  read -p "server: " server
done

declare -r info=$(curl -s -H "Content-Type: application/json" -X GET http://${server}:${port}/v1/info)

declare -r date=$(jq -r '.date' <<< "$info")
declare -r proof="$(echo -n "$date" | openssl dgst -sha256 -hmac "$hashpass" -binary -r| openssl base64)"
 
declare -r template='{"date":"%s","username":"%s","proof":"%s"}'

declare -r login=$(printf "$template" "$date" "$username" "$proof" |
  curl -s -H "Content-Type: application/json" -X POST -d @- http://${server}:${port}/v1/auth/login
)
declare -r token="$(jq -r '.token' <<< "$login")"
echo $token
exit 0
