#!/usr/bin/env bash
declare -r sdir=$(dirname -- "$(readlink -ne -- "$0")")	#Full sdir

usage() {
    declare -r name=$(basename "$0")
    echo Sign-up account
    echo -e "Usage:\n\t $name [username[@server[:port]]]"
    exit 1
}

die() {
  echo "$@" && exit 1
}

#declare -r pattern='^([[:alnum:]]+)?(@([[:alnum:]]+)?(:([[:digit:]]+))?)?$'
declare -r pattern='^([[:alnum:]]+)(@([^:]+)(:([0-9]+))?)?$'

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

declare hashpass="$(
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

while [[ ! ${email} =~ ^.+@.+$ ]]
do
  read -p "Email: " email
done

declare answer=$(
  declare -r template='{"email":"%s","username":"%s","hashpass":"%s"}'
  #jq -n --arg email "$email" --arg user "$username" --arg pass "$hashpass" '{email: $email, username: $user, hashpass: $pass }' |
  printf "$template" "$email" "$username" "$hashpass" |
  curl -s -H "Content-Type: application/json" -X POST -d @- http://${server}:${port}/v1/auth/signup
)

declare echallenge=$(echo $answer | jq -r '.echallenge')
IFS='|' read -r iv salt enc <<< "$echallenge"

iv="$(openssl base64 -d <<< "$iv" | hexdump -ve '/1 "%02x"')"
salt="$(openssl base64 -d <<< "$salt" | hexdump -ve '/1 "%02x"')"

declare digest=$(echo $answer | jq -r '.digest')
declare ok=$(echo $answer | jq -r '.response.ok')

[[ $ok == 'true' ]] || die "Answer receveid is not OK: $answer"

while [[ ${code:+x} != x ]]
do
  read -p "Received code (sent to $email): " code < /dev/tty
done

declare mydigest="$(echo -n "$hashpass" | openssl dgst -sha256 -hmac "$code" -binary -r| openssl base64)"

[[ $digest == $mydigest ]] || die "Digest don't match. Be careful with any possible Scam"

declare -r key="$(openssl aes-256-cbc -pbkdf2 -iter 10000 -k "$code" -S "$salt" -P|awk -F= '/^key=/ {print $2}')"

declare challenge="$(echo "$enc" | openssl aes-256-cbc -d -a -K "$key" -iv "$iv")"

declare proof="$(echo -n "$challenge" | openssl dgst -sha256 -hmac "$hashpass" -binary -r| openssl base64)"

# const confirm = { email, username, proof }
# const res = await post('/v1/auth/confirm', confirm)

declare response=$(
  declare -r template='{"email":"%s","username":"%s","proof":"%s"}'
  #jq -n --arg email "$email" --arg user "$username" --arg proof "$proof" '{email: $email, username: $user, proof: $proof }' |
  printf "$template" "$email" "$username" "$proof" |
  curl -s -H "Content-Type: application/json" -X POST -d @- http://${server}:${port}/v1/auth/confirm
)

echo $response |jq .

exit 0