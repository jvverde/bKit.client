#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR=$(cygpath "$(dirname "$(readlink -f "$0")")")	#Full DIR

[[ $1 == "-f" ]] && FORCE=$1 && shift
[[ $1 == "-c" ]] && CHECK=$1 && shift

BACKUPDIR="$1"

die() { echo -e "$@"; exit 1; }

[[ $BACKUPDIR =~ ^[a-zA-Z]: ]]  || die "Usage:\n\t$0 [-u|-f] Drive:\\full-path-of-backup-dir"

BUDIR="$(cygpath "$BACKUPDIR")"

echo Send manifest for $BACKUPDIR
[[ -d "$BUDIR" ]] || die "The directory $BACKUPDIR ($BUDIR)doesn't exist"

DRIVE=${BACKUPDIR%%:*}
DRIVE=${DRIVE^^}
BPATH=${BACKUPDIR#*:} #remove anything until character ':' inclusive
BPATH=${BPATH#*\\}    #remove anything until character '\' inclusive
BPATH=${BPATH%%\\}    #remove last, if exist, character '\'

. $SDIR/drive.sh
RID="$DRIVE.$VOLUMESERIALNUMBER.$VOLUMENAME.$DRIVETYPE.$FILESYSTEM/.bkit/$BPATH"

$SDIR/manifest.sh $FORCE $BACKUPDIR 2>&1 |xargs -d '\n' -I{} echo manifest: {}
SENT=$SDIR/cache/$RID/.sent
[[ -n ${CHECK:+x} ]] && [[ -f $SENT ]] && echo No need to sent it again && exit 0

RSYNC=$(find "$SDIR/3rd-party" -type f -name "rsync.exe" -print | head -n 1)
[[ -f $RSYNC ]] || die Rsync.exe not found
CONF="$SDIR/conf/conf.init"
[[ -f $CONF ]] || die Cannot found configuration file at $CONF
source $CONF

EXEC="$RSYNC --password-file="$SDIR/conf/pass.txt" -rlitzvvhR --chmod=D750,F640 --inplace --fuzzy --stats $SDIR/cache/./$RID/manifest $MANIFURL/"
$EXEC 2>&1 |xargs -d '\n' -I{} echo rsync: {}

RETURN=${PIPESTATUS[0]}
[ $RETURN -ne 0 ] && echo "Fail to send manifest. Exit value of rsync is non null: $RETURN" && exit 1
echo $(date -R) >> $SENT
echo Sent manifest of $BACKUPDIR 