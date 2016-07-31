#!/bin/bash
DIR=$(dirname "$(readlink -f "$0")")	#Full DIR
SECTION=bkit
PORT=8733
USER=user
PASS=us3r
SERVER="$1"
die() { echo -e "$@"; exit 1; }
[[ -z $SERVER ]] && die "Usage:\n\t$0 server-address"
echo Contacting the server ... please wait!

find $DIR -type f -path "*/cygwin/*" -name "nc.exe" -print | 
xargs -L 1 -I{} sh -c "{} -z $SERVER $PORT" || die Server $SERVER not found

. computer.sh

CONFDIR="$DIR/conf"
mkdir -p "$CONFDIR"


INITFILE=$CONFDIR/conf.init

echo Writing configuration to $INITFILE

echo "BACKUPURL=rsync://$USER@$SERVER:$PORT/$DOMAIN.$NAME.$UUID.data" > $INITFILE
echo "MANIFURL=rsync://$USER@$SERVER:$PORT/$DOMAIN.$NAME.$UUID.manifest" >> $INITFILE

PASSFILE=$CONFDIR/pass.txt
echo $PASS > $PASSFILE
chmod 600 $PASSFILE

RSYNC=$(find $DIR -type f -name "rsync.exe" -print | head -n 1)
[[ -f $RSYNC ]] || die "Rsync.exe not found"

${RSYNC} -rltvvhR --inplace --stats ${CONFDIR}/./ rsync://admin\@${SERVER}:${PORT}/${SECTION}/${DOMAIN}/${NAME}/${UUID}
RET=$?
[[ $RET -ne 0 ]] && echo "Exit value of rsync is non null: $RET" && exit 1
