#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR=$(cygpath "$(dirname "$(readlink -f "$0")")")	#Full DIR

[[ $1 == "-u" ]] && UPDATE=true && shift
[[ $1 == "-f" ]] && FORCE=true && shift
BACKUPDIR="$1"

die() { echo -e "$@"; exit 1; }

[[ $BACKUPDIR =~ ^[a-zA-Z]: ]]  || die "Usage:\n\t$0 [-u|-f] Drive:\\full-path-of-backup-dir"

BUDIR="$(cygpath "$BACKUPDIR")"

[[ -d "$BUDIR" ]] || die "The directory $BACKUPDIR ($BUDIR)doesn't exist"

DRIVE=${BACKUPDIR%%:*}
DRIVE=${DRIVE^^}
BPATH=${BACKUPDIR#*:} #remove anything until character ':' inclusive
BPATH=${BPATH#*\\}    #remove anything until character '\' inclusive
BPATH=${BPATH%%\\}    #remove last, if exist, character '\'
VARS="$(wmic logicaldisk WHERE "Name='$DRIVE:'" GET Name,VolumeSerialNumber,VolumeName,Description /format:textvaluelist.xsl |sed 's#\r##g' |awk -F "=" '$1 {print toupper($1) "=" "\"" $2 "\""}')"
eval "$VARS"
DESCRIPTION=$(echo $DESCRIPTION | sed 's#[^a-z]#-#gi')
RID="$DRIVE.$VOLUMESERIALNUMBER.${VOLUMENAME:-_}.$DESCRIPTION/${BPATH}"
MANIFESTDIR=$SDIR/cache/$RID
mkdir -p "$MANIFESTDIR"
MANIFESTFILE=$MANIFESTDIR/manifest
if [[ $FORCE || ! -f "$MANIFESTFILE" || $UPDATE && $(find "$MANIFESTFILE" -mtime +1) ]] 
then
  echo Get manifest of $BACKUPDIR
  find "$BUDIR" -type f -printf "%P:%s\n" |LC_ALL=C sort > "$MANIFESTFILE"
fi
RSYNC=$(find "$SDIR" -type f -name "rsync.exe" -print | head -n 1)
[[ -f $RSYNC ]] || die Rsync.exe not found
CONF="$SDIR/conf/conf.init"
[[ -f $CONF ]] || die Cannot found configuration file at $CONF
source $CONF

EXEC="$RSYNC --password-file="$SDIR/conf/pass.txt" -rlitzvvhR --chmod=D750,F640 --inplace --fuzzy --stats $SDIR/cache/./ $MANIFURL/"
$EXEC >$SDIR/logs/manifest.rsync.log 2>$SDIR/logs/manifest.rsync.err

echo Sent manifest of $BACKUPDIR 