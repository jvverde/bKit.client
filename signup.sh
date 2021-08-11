#!/usr/bin/env bash
declare -r sdir=$(dirname -- "$(readlink -ne -- "$0")")	#Full sdir

usage() {
    declare -r name=$(basename "$0")
    echo Sign-up account
    echo -e "Usage:\n\t $name [USER[@SERVER[:PORT]]]"
    exit 1
}

die() {
  echo "$@" && exit 1
}

#declare -r pattern='^([[:alnum:]]+)?(@([[:alnum:]]+)?(:([[:digit:]]+))?)?$'
declare -r pattern='^([[:alnum:]]+)(@([^:]+)(:([0-9]+))?)?$'

if [[ "${1:+$1}" =~ $pattern ]]
then
  declare USER=${BASH_REMATCH[1]}
  declare SERVER=${BASH_REMATCH[3]}
  declare PORT=${BASH_REMATCH[5]}
fi

PORT=${PORT:-8765}
while [[ ${USER:+x} != x ]]
do
  read -p "User: " USER
done

declare hashpass="$(
  openssl dgst -sha512 -hex -r < <(
    while [[ ${PASS:+x} != x ]]
    do
      read -sp "Password for user $USER: " PASS
    done
    echo -n "$PASS"
  ) | awk '{print $1}'
)"

echo

while [[ ${SERVER:+x} != x ]]
do
  read -p "SERVER: " SERVER
done

while [[ ! ${EMAIL} =~ ^.+@.+$ ]]
do
  read -p "Email: " EMAIL
done

declare answer=$(
  jq -n --arg email "$EMAIL" --arg user "$USER" --arg pass "$hashpass" '{email: $email, username: $user, hashpass: $pass }' |
  curl -H "Content-Type: application/json" -X POST -d @- http://${SERVER}:${PORT}/v1/auth/signup |jq .
)

echo $answer
declare echallenge=$(echo $answer | jq -r '.echallenge')
IFS='|' read -r IV SALT ENC <<< "$echallenge"
echo "IV=$IV"
echo "SALT=$SALT"
echo "ENC=$ENC"
IV="$(openssl base64 -d <<< "$IV" | hexdump -ve '/1 "%02x"')"
SALT="$(openssl base64 -d <<< "$SALT" | hexdump -ve '/1 "%02x"')"
echo "IV=$IV"
echo "SALT=$SALT"
declare digest=$(echo $answer | jq -r '.digest')
declare ok=$(echo $answer | jq -r '.response.ok')

[[ $ok == 'true' ]] || die "Answer receveid is not OK: $answer"

while [[ ${CODE:+x} != x ]]
do
  read -p "Received CODE (sent to $EMAIL): " CODE < /dev/tty
done

echo CODE=$CODE

declare mydigest="$(echo -n "$hashpass" | openssl dgst -sha256 -hmac "$CODE" -binary -r| openssl base64)"

[[ $digest == $mydigest ]] || die "Digest don't match. Be careful with any possible Scam"

#  const proof = hmac(received.challenge, hashpass)
#  const confirm = { email, username, proof }
#  const res = await post('/v1/auth/confirm', confirm)
#  const [iv, salt, encrypted] = text.split('|').map(e => Buffer.from(e, 'base64'))
# openssl aes-256-cbc -d -a -in secrets.txt.enc -out secrets.txt.new

KEY="$(openssl aes-256-cbc -pbkdf2 -iter 10000 -k "$CODE" -S "$SALT" -P|awk -F= '/^key=/ {print $2}')"

declare challenge="$(echo "$ENC" | openssl aes-256-cbc -d -a -K "$KEY" -iv "$IV")"
echo "challenge=$challenge"

declare proof="$(echo -n "$challenge" | openssl dgst -sha256 -hmac "$hashpass" -binary -r| openssl base64)"
echo "proof=$proof"

# const confirm = { email, username, proof }
# const res = await post('/v1/auth/confirm', confirm)

declare response=$(
  jq -n --arg email "$EMAIL" --arg user "$USER" --arg proof "$proof" '{email: $email, username: $user, proof: $proof }' |
  curl -s -H "Content-Type: application/json" -X POST -d @- http://10.1.1.4:8765/v1/auth/confirm |jq .
)

echo $response

exit 0