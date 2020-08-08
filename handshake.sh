#!/usr/bin/env bash
declare -r sdir=$(dirname -- "$(readlink -ne -- "$0")")	#Full sdir
source "$sdir/lib/functions/all.sh"

usage() {
    declare -r name=$(basename -s .sh "$0")
    echo Restore from backup one or more directories of files
    echo -e "Usage:\n\t $name [-p port] Server-address"
    exit 1
}

if [[ $1 == -p ]];
then
  declare -r PORT="$2" && shift && shift
else
  declare -r PORT=8760
fi

declare -r server="${1:-"$($sdir/server.sh -r)"}"

[[ -n $server ]] || usage
echo Contacting the server ... please wait!
exists nc && { nc -z $server $PORT 2>&1 || die Server $server not found;}

while [[ ${BKIT_ACCOUNT:+x} != x ]]
do
  read -p "bKit username: " BKIT_ACCOUNT
  unset ACCOUNT_PASS 
done

while [[ ${ACCOUNT_PASS:+x} != x ]]
do
  read -sp "${BKIT_ACCOUNT} password: " ACCOUNT_PASS
  #${username}|bKit|${password}
  ACCOUNT_PASS="$(echo -n "${BKIT_ACCOUNT}|bKit|${ACCOUNT_PASS}"|md5sum|awk '{print $1}')"
done

umask 077

declare -r confdir="$ETCDIR/server/$server/$BKIT_ACCOUNT"
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

openssl dgst -sha512 -hmac "$ACCOUNT_PASS" -hex -r < "$public/client.conf" |awk '{print $1}' > "$public/client.sign"

#find section = hmac(user, pass)
declare -r section="${BKIT_ACCOUNT}"

IFS='|' read -r domain name uuid <<<$("$sdir/lib/computer.sh")

declare -r clientid="${domain}/${name}/${uuid}/user/${BKITUSER}"

declare -r sign="$(
  echo -n "$clientid" |                                   #message(=clientid) to sign
  openssl dgst -sha512 -hmac "$ACCOUNT_PASS" -hex -r |  #sign with password
  awk '{print $1}'                                        #just remove the sencond column(= *stdin)
)"

declare -r url="rsync://${server}:${PORT}/${section}/$clientid/$sign"

rsync -rti --exclude="server.*" $FMT "$public/" "$url/" || die "Exit value of rsync is non null: $?"
rsync -rti --exclude="ssh-client.*" $FMT "$url/" "$public/" || die "Exit value of rsync is non null: $?"

declare -r serverconf="$public/server.conf"
[[ -e $serverconf ]] || die "I didn't receive server.conf"

declare -r serversign="$public/server.sign"
[[ -e $serversign ]] || die "I didn't receive server.sign"


#openssl enc -d -md sha256 -aes-256-cbc -kfile <(echo -n "mypass") -in <(echo -n "$secret"|base64 -d)
declare -r serify="$(
   openssl dgst -sha512 -hmac "${ACCOUNT_PASS}" -hex -r < "$serverconf"|  #sign with password
   awk '{print $1}'                                                #just remove the sencond column(= *stdin)
)"

declare -r ssign="$(cat "$serversign")"

[[ "$serify" == "$ssign" ]] || die Server signature not valid

source "$serverconf"
#extract secret and save it on private directory
declare -r secretfile="$private/secret"

openssl enc -d -md sha256 -aes-256-cbc -k "${ACCOUNT_PASS}" -in <(echo -n "$BKITSRV_ENCSECRET"|base64 -d) -out "$secretfile"
chmod 600 "$secretfile"

#add server ssh public key to known_hosts file
declare -r khfile="$private/known_hosts"
touch "$khfile"
ssh-keygen -R "$server" -f "$khfile" 2>/dev/null
#grep -Po "(?<=^sshkey=').+(?='\$)" "$serverconf" |xargs -rI{} echo "$server {}" >> "$khfile"
echo "$server $BKITSRV_SSHKEY" >> "$khfile"

#extract public key and store in on local private folder
#grep -Po "(?<=^pubkey=').+(?='\$)" "$serverconf" | base64 -d > "$private/server.pubkey"
echo -n "$BKITSRV_PUBKEY" | base64 -d > "$private/server.pubkey"

#setup configuration file to be used by clients scipts
declare -r conffile="$confdir/conf.init"

echo "Writing configuration to $conffile"
(
  cat "$serverconf"
  echo "SSH='ssh -i \"$private/ssh.key\" -o UserKnownHostsFile=\"$khfile\" rsyncd@${server} $BKITSRV_COMMAND'"
  echo "RSYNCURL='rsync://${BKITSRV_ACCOUNT}@$server:$BKITSRV_BPORT/$BKITSRV_SECTION'"
  echo "SSHURL='${BKITSRV_ACCOUNT}@$server::$BKITSRV_SECTION'"
  echo "BACKUPURL='${BKITSRV_ACCOUNT}@$server::$BKITSRV_SECTION'"
  echo "PASSFILE='$secretfile'"
  echo "SERVER='$server'"
  echo "BKIT_ACCOUNT='$BKIT_ACCOUNT'"
  echo "CONFDATE='$(date -Iseconds)'"
)> "$conffile"

#set default server if not defined yet
declare -r default="$ETCDIR/server/default"
[[ -d $default ]] || ln -svrfT "$confdir" "$default"

echo This is the content of init file in $conffile
echo '##########################'
cat "$conffile" | sed 's/^/\t/'
echo '##########################'
echo "Backup server $server setup successfully!"
echo "conffile=$conffile"

exit 0