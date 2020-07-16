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

bash "$sdir"/lib/keygen.sh -n "$server" "$confdir"		|| die "Can't generate a key"

declare -r conffile="$confdir/conf.init"

export RSYNC_PASSWORD

declare -r FMT='--out-format="%o|%i|%f|%c|%b|%l|%t"'

IFS='|' read -r DOMAIN NAME UUID <<<$("$sdir/lib/computer.sh")

declare syncd="$confdir/pub"					#public keys location
exists cygpath && syncd="$(cygpath -u "$syncd")"

#generate a random string to challenge the server
declare -r challenge="$(head -c 1000 </dev/urandom | tr -cd "[:alnum:]" | head -c 32)"
echo -n $challenge > "$syncd/challenge"

declare -r url="rsync://${RSYNC_USER}@${server}:${PORT}/${SECTION}/${DOMAIN}/${NAME}/${UUID}/user/${BKITUSER}"
echo url=$url
#Send public keys and challenge to the server
rsync -rltvhR $FMT "$syncd/./" "$url/" || die "Exit value of rsync is non null: $?"

#Read (back) public keys from server including (meanwhile) generated server public keys as well the encripted challenge
rsync -rlthgpR --no-owner $FMT "$url/./" "$syncd/" || die "Exit value of rsync is non null: $?"

#Now generate a password/secret by using a Diffie-Hellman algorithm
"$sdir/lib/genpass.sh" "$confdir"		|| die "Can't generate the pass"

#And check if challenged was well encripted
declare -r verify="$(openssl enc -aes256 -md SHA256 -base64 -pass file:"$confdir/.priv/secret" -d -in "$confdir/pub/verification")"
[[ $verify == $challenge ]] || die "Something was wrong with the produced key"
#rsync --dry-run -ai -e "ssh -i conf/id_rsa bkit@10.1.1.3 localhost 8730" admin@10.1.1.3::bkit tmp/

KH="$confdir/.priv/known_hosts"
touch "$KH"
ssh-keygen -R "$server" -f "$KH" && ssh-keyscan -H -t ecdsa "$server" >> "$KH"

echo Writing configuration to $conffile
(
  read SECTION <"$confdir/pub/section"
  read BKITUSER <"$confdir/pub/user"
	read COMMAND <"$confdir/pub/command"
	#echo "BACKUPURL=rsync://user@$server:$BPORT/$SECTION"
	echo "SSH='ssh -i \"$confdir/.priv/ssh.key\" -o UserKnownHostsFile=\"$KH\" rsyncd@$server $COMMAND'"
	echo "RSYNCURL='rsync://${BKITUSER}@$server:$BPORT/$SECTION'"
	echo "SSHURL='${BKITUSER}@$server::$SECTION'"
	echo "BACKUPURL='${BKITUSER}@$server::$SECTION'"
	echo "PASSFILE='$confdir/.priv/secret'"
	OS=$(uname -o|tr '[:upper:]' '[:lower:]')
	ARCH=$(uname -m|tr '[:upper:]' '[:lower:]')
	[[ $ARCH == x86_64 ]] && ARCH=x64 || ARCH=ia32
	[[ $OS == cygwin ]] && OS=win32 || OS=linux
	echo "UPDATERSRC=rsync://admin@$server:$UPORT/bkit-update/bKit-$OS-$ARCH/./"
	[[ -d $sdir/conf ]] && find "$sdir/conf" -maxdepth 1 -type f -iname 'rsync*.conf' -exec cat "{}" ';'
)> "$conffile"

declare -r default="$(dirname -- "$confdir")/default"

[[ -d $default ]] || ln -svrfT "$confdir" "$default"

echo This is the content of init file in $conffile
echo '##########################'
cat "$conffile" | sed 's/^/\t/'
echo '##########################'
echo "Backup server $server setup successfully!"
