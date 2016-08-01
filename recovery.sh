#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR=$(cygpath "$(dirname "$(readlink -f "$0")")")	#Full DIR

die() { echo -e "$@" ; exit 1; }

function get_json(){
	grep -Po '(?<="'$1'":")(?:|.*?[^\\])(?=")'
}

RESOURCE=$1
BACKUP=$(get_json backup < $RESOURCE)
DISK=$(get_json drive < $RESOURCE)
COMPUTER=$(get_json computer < $RESOURCE)
BPATH=$(get_json path < $RESOURCE )
ENTRY=$(get_json entry < $RESOURCE)

IFS='.' read -r DRIVE VOLUME NAME DESCRIPTION FS <<< "$DISK"
CURRENT_DRIVE=$($SDIR/findVolumeDrive.sh $VOLUME) || die Cannot found the volume $VOLUME on this computer
DST=$(cygpath $CURRENT_DRIVE)

. computer.sh                                                               #get $DOMAIN, $NAME and $UUID
THIS=$DOMAIN.$NAME.$UUID
[[ $THIS != $COMPUTER ]] && [[ -n $FORCE ]] && die This is not the same computer; 

CONF="$SDIR/conf/conf.init"
[[ -f $CONF ]] || die Cannot found configuration file at $CONF
. $CONF                                                                     #get configuration parameters

SRC=$(echo $BACKUPURL/$DISK/$BACKUP/./$BPATH/$ENTRY|sed s#/././#/./#)       #for cases where BPATH=.

RSYNC=$(find "$SDIR/3rd-party" -type f -name "rsync.exe" -print | head -n 1)
[[ -f $RSYNC ]] || die "Rsync.exe not found"

FMT='--out-format="%p|%t|%o|%i|%b|%l|%f"'
PASS="--password-file=$SDIR/conf/pass.txt"
PERM="--acls --owner --group --super --numeric-ids"
OPTIONS="--delete-delay --delay-updates --force --stats --fuzzy"

EXEC="$RSYNC -rlitzvvhR $PERM $OPTIONS $FMT $PASS $SRC $DST/"
$EXEC
echo $EXEC
