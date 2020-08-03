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
  read -p "bKit username: " CLIENT_USR
  unset CLIENT_PASS 
done

while [[ ${CLIENT_PASS:+x} != x ]]
do
  read -sp "bKit password: " CLIENT_PASS
  #${username}|bKit|${password}
  CLIENT_PASS="$(echo -n "${CLIENT_USR}|bKit|${CLIENT_PASS}"|md5sum|awk '{print $1}')"
done

umask 077

declare -r confdir="$ETCDIR/server/$server"
declare -r public="$confdir/pub"
declare -r private="$confdir/.priv"
mkdir -pv "$public"
mkdir -pv "$private"
declare -r sshpriv="$private/ssh.key"
[[ -e $sshpriv ]] && rm "$sshpriv" #rm any old key if exists
ssh-keygen -t ed25519 -f "$sshpriv" -q -N "" -C ""
chmod 600 "$sshpriv"
declare -t sshpub="$(ssh-keygen -f "$sshpriv" -y |base64 -w0)"

openssl ecparam -name secp256k1 -genkey -noout -out "$private/key.pem"  #generate a private key
declare -r pubkey="$(openssl ec -in "$private/key.pem" -pubout | base64 -w0)" #extract the public key and save it on client readable location

#Sign the public key with a user simetric key
{
  echo "sshkey='$sshpub'"
  echo "pubkey='$pubkey'"
} > "$public/client.conf"

openssl dgst -sha512 -hmac "$CLIENT_PASS" -hex -r < "$public/client.conf" |awk '{print $1}' > "$public/client.sign"

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
declare -r secretfile="$private/secret"
declare -r encsec="$(grep -Po "(?<=^secret=').+(?='\$)" "$serverconf")"
openssl enc -d -md sha256 -aes-256-cbc -k "${CLIENT_PASS}" -in <(echo -n "$encsec"|base64 -d) -out "$secretfile"
chmod 600 "$secretfile"

#add server ssh public key to known_hosts file
declare -r khfile="$private/known_hosts"
touch "$khfile"
ssh-keygen -R "$server" -f "$khfile" 2>/dev/null
grep -Po "(?<=^sshkey=').+(?='\$)" "$serverconf" |xargs -rI{} echo "$server {}" >> "$khfile"

#extract public key and store in on local private folder
grep -Po "(?<=^pubkey=').+(?='\$)" "$serverconf" | base64 -d > "$private/server.pubkey"

#setup configuration file to be used by clients scipts
declare -r conffile="$confdir/conf.init"

echo "Writing configuration to $conffile"
(
  declare -r bkitsection="$(grep -Po "(?<=^section=').+(?='\$)" "$serverconf")"
  declare -r bkituser="$(grep -Po "(?<=^user=').+(?='\$)" "$serverconf")"
  declare -r command="$(grep -Po "(?<=^command=').+(?='\$)" "$serverconf")"
  declare -r bport="$(grep -Po "(?<=^bport=').+(?='\$)" "$serverconf")"
  echo "SSH='ssh -i \"$private/ssh.key\" -o UserKnownHostsFile=\"$khfile\" rsyncd@${server} $command'"
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