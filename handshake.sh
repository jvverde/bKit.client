#!/usr/bin/env bash
declare -r sdir=$(dirname -- "$(readlink -ne -- "$0")")	#Full sdir
source "$sdir/lib/functions/all.sh"

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

while [[ ${CLIENT_USR:+x} != x ]]
do
  read -p "Rsync username: " CLIENT_USR
  unset CLIENT_PASS 
done

while [[ ${CLIENT_PASS:+x} != x ]]
do
  read -sp "Rsync password: " CLIENT_PASS
  CLIENT_PASS="$(echo -n "$CLIENT_PASS"|md5sum|awk '{print $1}')"
done

declare -r confdir="$ETCDIR/server/$server"

"$sdir"/lib/keys-ssh.sh -n "$server" "$confdir" || die "Can't generate a key"

declare -r public="$confdir/pub"
declare -t publickey="$public/ssh-client.pub"

[[ -e "$publickey" ]] || die "public key on '$public' is missing"

umask 077
#Sign the public key with user simetric key
declare -t keyhmac="$public/ssh-client.hmac"
openssl dgst -sha512 -hmac "$CLIENT_PASS" -hex -r < "$publickey" |awk '{print $1}' > "$keyhmac"

#find section = hmac(user, pass)
declare -r section="${CLIENT_USR}"

IFS='|' read -r domain name uuid <<<$("$sdir/lib/computer.sh")

declare -r clientid="${domain}/${name}/${uuid}/user/${BKITUSER}"

declare -r sign="$(
  echo -n "$clientid" |                                   #message(=clientid) to sign
  openssl dgst -sha512 -hmac "$CLIENT_PASS" -hex -r |  #sign with password
  awk '{print $1}'                                        #just remove the sencond column(= *stdin)
)"

declare -r url="rsync://${server}:${PORT}/${section}/$clientid/$sign"

rsync -rti --exclude="server.*" $FMT "$public/" "$url/" || die "Exit value of rsync is non null: $?"
rsync -rti --exclude="ssh-client.*" $FMT "$url/" "$public/" || die "Exit value of rsync is non null: $?"

declare -r serverconf="$public/server.conf"
[[ -e $serverconf ]] || die "I didn't receive server.conf"

declare -r serversign="$public/server.sign"
[[ -e $serversign ]] || die "I didn't receive server.sign"


#openssl enc -d -md sha256 -aes-256-cbc -kfile <(echo -n "0rd1s1") -in <(echo -n "$secret"|base64 -d)
declare -r serify="$(
   openssl dgst -sha512 -hmac "${CLIENT_PASS}" -hex -r < "$serverconf"|  #sign with password
   awk '{print $1}'                                                #just remove the sencond column(= *stdin)
)"

declare -r ssign="$(cat "$serversign")"

[[ "$serify" == "$ssign" ]] || die Server signature not valid

#extract secret and save it on private directory
declare -r secretfile="$confdir/.priv/secret"
declare -r encsec="$(grep -Po "(?<=^secret=').+(?='\$)" "$serverconf")"
openssl enc -d -md sha256 -aes-256-cbc -k "${CLIENT_PASS}" -in <(echo -n "$encsec"|base64 -d) -out "$secretfile"

#add server public key to known_hosts file
declare -r khfile="$confdir/.priv/known_hosts"
touch "$khfile"
ssh-keygen -R "$server" -f "$khfile" 2>/dev/null
grep -Po "(?<=^pubkey=').+(?='\$)" "$serverconf" |xargs -rI{} echo "$server {}" >> "$khfile"

#setup configuration file to be used by clients scipts
declare -r conffile="$confdir/conf.init"

echo "Writing configuration to $conffile"
(
  declare -r bkitsection="$(grep -Po "(?<=^section=').+(?='\$)" "$serverconf")"
  declare -r bkituser="$(grep -Po "(?<=^user=').+(?='\$)" "$serverconf")"
  declare -r command="$(grep -Po "(?<=^command=').+(?='\$)" "$serverconf")"
  declare -r bport="$(grep -Po "(?<=^bport=').+(?='\$)" "$serverconf")"
  echo "SSH='ssh -i \"$confdir/.priv/ssh.key\" -o UserKnownHostsFile=\"$khfile\" rsyncd@${server} $command'"
  echo "RSYNCURL='rsync://${bkituser}@$server:$bport/$bkitsection'"
  echo "SSHURL='${bkituser}@$server::$bkitsection'"
  echo "BACKUPURL='${bkituser}@$server::$bkitsection'"
  echo "PASSFILE='$secretfile'"
)> "$conffile"

#set default server if not defined yet
declare -r default="$(dirname -- "$confdir")/default"
[[ -d $default ]] || ln -svrfT "$confdir" "$default"

echo This is the content of init file in $conffile
echo '##########################'
cat "$conffile" | sed 's/^/\t/'
echo '##########################'
echo "Backup server $server setup successfully!"

exit 0