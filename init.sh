#!/usr/bin/env bash
SDIR=$(dirname "$(readlink -f "$0")")	#Full SDIR

SECTION=bkit
PORT=8730
BPORT=8731
RPORT=8732
UPORT=8733
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

KEY="$("$SDIR"/keygen.sh -n "$SERVER")" 		|| die "Can't generate a key"
CONFDIR="$(dirname -- "$(readlink -ne -- "$KEY")")" 	|| die "Can't find config directory"
KEYFILE="$(basename -- "$KEY")"

USER="$(basename -- "$(dirname -- "$CONFDIR")")"	|| die "Can't found USER"	#expected /somepath/user/server from CONFDIR
INITFILE=$CONFDIR/conf.init
exists cygpath && INITFILE="$(cygpath -w "$INITFILE")"

exists rsync || die rsync not found

export RSYNC_PASSWORD="4dm1n"
FMT='--out-format="%o|%i|%f|%c|%b|%l|%t"'

IFS='|' read -r DOMAIN NAME UUID <<<$("$SDIR/computer.sh")
rsync -rltvhR $FMT "$CONFDIR/./$KEYFILE" "rsync://admin@${SERVER}:${PORT}/${SECTION}/${DOMAIN}/${NAME}/${UUID}/${USER}/"
rsync -rlthgpR --no-owner $FMT "rsync://admin@${SERVER}:${PORT}/${SECTION}/${DOMAIN}/${NAME}/${UUID}/${USER}/./pass.txt" "${CONFDIR}/" 
exit
#rsync --dry-run -ai -e "ssh -i conf/id_rsa bkit@10.1.1.3 localhost 8730" admin@10.1.1.3::bkit tmp/
RET=$?
[[ $RET -ne 0 ]] && echo "Exit value of rsync is non null: $RET" && exit 1

echo Writing configuration to $INITFILE
(
	echo "BACKUPURL=rsync://$USER@$SERVER:$BPORT/$DOMAIN.$NAME.$UUID"
	echo "RECOVERURL=rsync://$USER@$SERVER:$RPORT/$DOMAIN.$NAME.$UUID"
	OS=$(uname -o|tr '[:upper:]' '[:lower:]')
	ARCH=$(uname -m|tr '[:upper:]' '[:lower:]')
	[[ $ARCH == x86_64 ]] && ARCH=x64 || ARCH=ia32
	[[ $OS == cygwin ]] && OS=win32 || OS=linux
	echo "UPDATERSRC=rsync://admin@$SERVER:$UPORT/bkit-update/bKit-$OS-$ARCH/./"
)> "$INITFILE"

echo This is the content of init file in $INITFILE
echo '##########################'
cat "$INITFILE"
echo '##########################'
echo "Backup server $SERVER setup successfully!"
