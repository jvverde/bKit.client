#!/usr/bin/env bash
declare -r sdir=$(dirname -- "$(readlink -ne -- "$0")")	#Full sdir
source "$sdir/lib/functions/all.sh"

declare SECTION=bkit
declare -r PORT=8760
declare -r BPORT=8761
declare -r RPORT=8762
declare -r UPORT=8763

declare -r server="${1:-"$($sdir/server.sh)"}"

usage() {
    declare -r name=$(basename -s .sh "$0")
    echo Restore from backup one or more directories of files
    echo -e "Usage:\n\t $name Server-address"
    exit 1
}

[[ -n $server ]] || usage
echo Contacting the server ... please wait!
exists nc && { nc -z $server $PORT 2>&1 || die Server $server not found;}

while [[ ${RSYNC_USER:+x} != x ]]
do
  read -p "Rsync username: " RSYNC_USER
  unset RSYNC_PASSWORD 
done

SECTION="$RSYNC_USER"

while [[ ${RSYNC_PASSWORD:+x} != x ]]
do
  read -sp "Rsync password: " RSYNC_PASSWORD
  echo
done


declare -r confdir="$ETCDIR/server/$server"

"$sdir"/lib/keys-ssh.sh -n "$server" "$confdir" || die "Can't generate a key"

declare -r public="$confdir/pub"
declare -t publickey="$public/ssh-client.pub"

[[ -e "$publickey" ]] || die "public key on '$public' is missing"

umask 077
#Sign the public key with user simetric key
declare -t keyhmac="$public/ssh-client.hmac"
openssl dgst -sha512 -hmac "$RSYNC_PASSWORD" -hex -r < "$publickey" |awk '{print $1}' > "$keyhmac"

#find section = hmac(user, pass)
declare -r section="${RSYNC_USER}#$(
  echo -n "$RSYNC_USER" |                                 #messsage(=user) to sign
  openssl dgst -sha512 -hmac "$RSYNC_PASSWORD" -hex -r |  #sign with password
  awk '{print $1}'                                        #just remove the sencond column(= *stdin)
)"

IFS='|' read -r domain name uuid <<<$("$sdir/lib/computer.sh")

declare -r clientid="${domain}/${name}/${uuid}/user/${BKITUSER}"

declare -r sign="$(
  echo -n "$clientid" |                                   #message(=clientid) to sign
  openssl dgst -sha512 -hmac "$RSYNC_PASSWORD" -hex -r |  #sign with password
  awk '{print $1}'                                        #just remove the sencond column(= *stdin)
)"

declare -r url="rsync://${server}:${PORT}/${section}/$clientid/$sign"

rsync -rti --exclude="ssh-server.*" $FMT "$public/" "$url/" || die "Exit value of rsync is non null: $?"
rsync -rti --exclude="ssh-client.*" $FMT "$url/" "$public/" || die "Exit value of rsync is non null: $?"

declare -r verify="$(
  openssl dgst -sha512 -hmac "${RSYNC_PASSWORD}" -hex -r < "$public/secret.enc"|  #sign with password
  awk '{print $1}'                                                #just remove the sencond column(= *stdin)
)"

declare -r secsign="$(cat "$public/secret.hmac")"

[[ "$verify" == "$secsign" ]] || die Secret signature not valid

declare -r secret="$confdir/.priv/secret"

openssl enc -d -md sha256 -aes-256-cbc -k "${RSYNC_PASSWORD}" -in "$public/secret.enc" -out "$secret"

exit 0