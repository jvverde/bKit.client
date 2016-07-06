#!/bin/bash
DIR=$(dirname "$(readlink -f "$0")")	#Full DIR
SECTION=bkit
PORT=8733
USER=user
PASS=us3r
SERVER=$1
die() { echo "$@"; exit 1; }
[[ -z ${SERVER+x} ]] && die "Usage:\n\t$0 [-m] server-address"
NC=$(find $DIR -type f -path "*/cygwin/*" -name "nc.exe" -print | head -n 1)
echo Contacting the server ... please wait!
[[ ! -f $NC ]] ||  $NC -z $SERVER $PORT 2>/dev/null && echo "Server OK" || die "Server $SERVER not respond on port $PORT"
echo Continue...
#exit

UUID="$(wmic csproduct get uuid /format:textvaluelist.xsl |awk -F "=" 'tolower($1) ~ /uuid/ {print $2}' | sed '#\r+##g')"
DOMAIN="$(wmic computersystem get domain /format:textvaluelist.xsl |awk -F "=" 'tolower($1) ~  /domain/ {print $2}' | sed '#\r+##g')"
NAME="$(wmic computersystem get name /format:textvaluelist.xsl |awk -F "=" 'tolower($1) ~  /name/ {print $2}' | sed '#\r+##g')"

RSYNC=$(find $DIR -type f -name "rsync.exe" -print | head -n 1)
#echo $RSYNC
RUNDIR="$DIR/run"
CONFDIR="$DIR/rconf"
mkdir -p "$RUNDIR"
mkdir -p "$CONFDIR"

cat > "$CONFDIR/conf.init" <<EOL
BACKUPURL="rsync://$USER\@$SERVER:$PORT/$DOMAIN.$NAME.$UUID"
MANIFURL="rsync://$USER\@$SERVER:$PORT/$DOMAIN.$NAME.$UUID.manif"
ACLSURL="rsync://$USER\@$SERVER:$PORT/$DOMAIN.$NAME.$UUID.acls"
PASS="$PASS"
EOL

${RSYNC} -rltvvhR --inplace --stats ${RUNDIR}/./ rsync://admin\@${SERVER}:${PORT}/${SECTION}/win/${DOMAIN}/${NAME}/${UUID}

[[ "$?" -ne 0 ]] && echo "Exit value of rsync is non null: $?" && exit 1
