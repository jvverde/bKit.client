#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR=$(cygpath "$(dirname "$(readlink -f "$0")")")	#Full DIR
[[ $1 == '-log' ]] && shift && exec 1>$1 2>&1 && shift

BACKUPDIR="$1"
MAPDRIVE="$2"

die() { echo -e "$@"; exit 1; }

[[ $BACKUPDIR =~ ^[a-zA-Z]: ]] || die "Usage:\n\t$0 Drive:\\backupDir mapDriveLetter:"
[[ $MAPDRIVE =~ ^[a-zA-Z]:$ ]] || die "Usage:\n\t$0 Drive:\\backupDir mapDriveLetter:"

echo Backup $1 on mapped drive $2

$SDIR/manifest.sh $BACKUPDIR 2>&1 |xargs -I{} echo manifest: {}
echo 'Manifest done'
$SDIR/acls.sh $BACKUPDIR 2>&1 |xargs -I{} echo acls: {}
echo 'ACLs done'

DRIVE=${BACKUPDIR%%:*}
DRIVE=${DRIVE^^}

BPATH=${BACKUPDIR#*:} #remove anything before character ':' inclusive
BPATH=${BPATH#*\\}    #remove anything before character '\' inclusive
[[ -n $BPATH ]] && BPATH="$(cygpath "$BPATH")"

ROOT="$(cygpath "$MAPDRIVE")"
BUDIR=$ROOT/$BPATH

[[ -d "$BUDIR" ]] || die "The mapped directory $BUDIR doesn't exist"

. $SDIR/drive.sh
RID="$DRIVE.$VOLUMESERIALNUMBER.$VOLUMENAME.$DRIVETYPE.$FILESYSTEM"
METADATADIR=$SDIR/cache/$RID
CONF="$SDIR/conf/conf.init"
[[ -f $CONF ]] || die Cannot found configuration file at $CONF
source $CONF

RSYNC=$(find $SDIR -type f -name "rsync.exe" -print | head -n 1)
[[ -f $RSYNC ]] || die "Rsync.exe not found"

FMT='--out-format="%p|%t|%o|%i|%b|%l|%f"'
EXC="--exclude-from=$SDIR/conf/excludes.txt"
PASS="--password-file=$SDIR/conf/pass.txt"
OPTIONS="--chmod=D750,F640 --inplace --delete-delay --force --delete-excluded --stats --fuzzy"
${RSYNC} -rlitzvvhR $OPTIONS $PASS $FMT $EXC $METADATADIR/./.bkit/$BPATH $ROOT/./$BPATH $BACKUPURL/$RID/current/ 2>&1 |xargs -I{} echo rsync: {}

[[ "$?" -ne 0 ]] && echo "Exit value of rsync is non null: $?" && exit 1

echo Backup of $BACKUPDIR done
