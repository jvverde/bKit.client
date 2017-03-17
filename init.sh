#!/bin/bash
DIR=$(dirname "$(readlink -f "$0")")	#Full DIR
SECTION=bkit
PORT=8730
BPORT=8731
RPORT=8732
UPORT=8733
USER=user
PASS=us3r
SERVER="$1"

die() { echo -e "$@">&2; exit 1; }
exists() { type "$1" >/dev/null 2>&1;}

[[ -z $SERVER ]] && die "Usage:\n\t$0 server-address"
echo Contacting the server ... please wait!
exists nc && { nc -z $SERVER $PORT 2>&1 || die Server $SERVER not found;}

source "$DIR/computer.sh"

CONFDIR="$DIR/conf"
mkdir -p "$CONFDIR"


INITFILE=$CONFDIR/conf.init
INITPATH=$INITFILE
exists cygpath && INITPATH=$(cygpath -w "$INITFILE")

echo Writing configuration to $INITPATH
(
	echo "BACKUPURL=rsync://$USER@$SERVER:$BPORT/$DOMAIN.$NAME.$UUID"
	echo "RECOVERURL=rsync://$USER@$SERVER:$RPORT/$DOMAIN.$NAME.$UUID"
	echo "UPDATERURL=rsync://admin@$SERVER:$UPORT/bkit-update"
)> "$INITFILE"

PASSFILE=$CONFDIR/pass.txt
echo $PASS > "$PASSFILE"
chmod 600 "$PASSFILE"

exists rsync || die rsync not found

export RSYNC_PASSWORD="4dm1n"
FMT='--out-format="%o|%i|%f|%c|%b|%l|%t"'

rsync -rltvhR $FMT --inplace --stats "${CONFDIR}/./" rsync://admin\@${SERVER}:${PORT}/${SECTION}/${DOMAIN}/${NAME}/${UUID}
RET=$?
[[ $RET -ne 0 ]] && echo "Exit value of rsync is non null: $RET" && exit 1


echo This is the content of init file in $INITPATH
echo '##########################'
cat "$INITFILE"
echo '##########################'
echo "Backup server setup successfully!"
