#!/bin/bash
DIR=$(dirname "$(readlink -f "$0")")	#Full DIR
SECTION=bkit
PORT=8730
BPORT=8731
RPORT=8732
USER=user
PASS=us3r
SERVER="$1"
die() { echo -e "$@"; exit 1; }
[[ -z $SERVER ]] && die "Usage:\n\t$0 server-address"
echo Contacting the server ... please wait!
type nc 2>/dev/null 1>&2 && { nc -z $SERVER $PORT || die Server $SERVER not found;}

source computer.sh

CONFDIR="$DIR/conf"
mkdir -p "$CONFDIR"


INITFILE=$CONFDIR/conf.init

echo Writing configuration to $INITFILE
(
	echo "BACKUPURL=rsync://$USER@$SERVER:$BPORT/$DOMAIN.$NAME.$UUID"
	echo "RECOVERURL=rsync://$USER@$SERVER:$RPORT/$DOMAIN.$NAME.$UUID"
)> "$INITFILE"

PASSFILE=$CONFDIR/pass.txt
echo $PASS > "$PASSFILE"
chmod 600 "$PASSFILE"

type rsync 2>/dev/null 1>&2 || die rsync not found

rsync -rltvvhR --inplace --stats "${CONFDIR}/./" rsync://admin\@${SERVER}:${PORT}/${SECTION}/${DOMAIN}/${NAME}/${UUID}
RET=$?
[[ $RET -ne 0 ]] && echo "Exit value of rsync is non null: $RET" && exit 1
