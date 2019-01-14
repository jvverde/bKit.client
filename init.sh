#!/usr/bin/env bash
SDIR=$(dirname -- "$(readlink -ne -- "$0")")	#Full SDIR

SECTION=bkit
PORT=8760
BPORT=8761
RPORT=8762
UPORT=8763
USER=user
PASS=us3r
SERVER="$1"
CERT="${2:-default}"

die() { echo -e "$@">&2; exit 1; }
exists() { type "$1" >/dev/null 2>&1;}

usage() {
    NAME=$(basename -s .sh "$0")
    echo Restore from backup one or more directories of files
    echo -e "Usage:\n\t $NAME Server-address"
    exit 1
}

[[ -n $SERVER ]] || usage
echo Contacting the server ... please wait!
exists nc && { nc -z $SERVER $PORT 2>&1 		|| die Server $SERVER not found;}

CONFDIR="$("$SDIR"/keygen.sh -n "$SERVER")" 		|| die "Can't generate a key"

USER="$(basename -- "$(dirname -- "$CONFDIR")")"	|| die "Can't found USER"	#expected /somepath/user/server from CONFDIR
INITFILE=$CONFDIR/conf.init

export RSYNC_PASSWORD="4dm1n"
FMT='--out-format="%o|%i|%f|%c|%b|%l|%t"'

IFS='|' read -r DOMAIN NAME UUID <<<$("$SDIR/computer.sh")

SYNCD="$CONFDIR/pub"					#public keys location
exists cygpath && SYNCD="$(cygpath -u "$SYNCD")"

CHALLENGE="$(head -c 1000 </dev/urandom | tr -cd "[:alnum:]" | head -c 32)"
echo -n $CHALLENGE > "$SYNCD/challenge"

#Send public keys and challenge to the server
rsync -rltvhR $FMT "$SYNCD/./" "rsync://admin@${SERVER}:${PORT}/${SECTION}/${DOMAIN}/${NAME}/${UUID}/user/${USER}/" || die "Exit value of rsync is non null: $?"

#Read (back) public keys from server including meanwhile generated server public keys as well the encripted challenge
rsync -rlthgpR --no-owner $FMT "rsync://admin@${SERVER}:${PORT}/${SECTION}/${DOMAIN}/${NAME}/${UUID}/user/${USER}/./" "$SYNCD/" || die "Exit value of rsync is non null: $?"

#Now generate a password/secret by using a Diffie-Hellman algorithm
"$SDIR/genpass.sh" "$CONFDIR"		|| die "Can't generate the pass"

#And check if challenged was well encripted
VERIF="$(openssl enc -aes256 -base64 -k "$(<"$CONFDIR/.priv/secret")" -d -in "$CONFDIR/pub/verification")"
[[ $VERIF == $CHALLENGE ]] || die "Something was wrong with the produced key"
#rsync --dry-run -ai -e "ssh -i conf/id_rsa bkit@10.1.1.3 localhost 8730" admin@10.1.1.3::bkit tmp/

KH="$CONFDIR/.priv/known_hosts"
touch "$KH"
ssh-keygen -R "$SERVER" -f "$KH" && ssh-keyscan -H -t ecdsa "$SERVER" >> "$KH"

echo Writing configuration to $INITFILE
(
	read SECTION <"$CONFDIR/pub/section"
	read COMMAND <"$CONFDIR/pub/command"
	#echo "BACKUPURL=rsync://user@$SERVER:$BPORT/$SECTION"
	echo "SSH='ssh -i \"$CONFDIR/.priv/ssh.key\" -o UserKnownHostsFile=\"$KH\" rsyncd@$SERVER $COMMAND'"
	echo "BACKUPURL='user@$SERVER::$SECTION'"
	echo "PASSFILE='$CONFDIR/.priv/secret'"
	OS=$(uname -o|tr '[:upper:]' '[:lower:]')
	ARCH=$(uname -m|tr '[:upper:]' '[:lower:]')
	[[ $ARCH == x86_64 ]] && ARCH=x64 || ARCH=ia32
	[[ $OS == cygwin ]] && OS=win32 || OS=linux
	echo "UPDATERSRC=rsync://admin@$SERVER:$UPORT/bkit-update/bKit-$OS-$ARCH/./"
	find "$SDIR/conf" -maxdepth 1 -type f -iname 'rsync*.conf' -exec cat "{}" ';'
)> "$INITFILE"
ln -svrfT "$CONFDIR" "$(dirname -- "$CONFDIR")/default"

echo This is the content of init file in $INITFILE
echo '##########################'
cat "$INITFILE"
echo '##########################'
echo "Backup server $SERVER setup successfully!"
