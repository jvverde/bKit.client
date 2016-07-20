#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR=$(cygpath "$(dirname "$(readlink -f "$0")")")	#Full DIR

[[ $1 == "-u" ]] && UPDATE=true && shift
[[ $1 == "-f" ]] && FORCE=true && shift
BACKUPDIR="$1"

die() { echo -e "$@"; exit 1; }

[[ $BACKUPDIR =~ ^[a-zA-Z]: ]]  || die "Usage:\n\t$0 [-u|-f] Drive:\\full-path-of-backup-dir"

BUDIR="$(cygpath "$BACKUPDIR")"

echo Check manifest for $BACKUPDIR
[[ -d "$BUDIR" ]] || die "The directory $BACKUPDIR ($BUDIR)doesn't exist"

DRIVE=${BACKUPDIR%%:*}
DRIVE=${DRIVE^^}
BPATH=${BACKUPDIR#*:} #remove anything until character ':' inclusive
BPATH=${BPATH#*\\}    #remove anything until character '\' inclusive
BPATH=${BPATH%%\\}    #remove last, if exist, character '\'
#VARS="$(wmic logicaldisk WHERE "Name='$DRIVE:'" GET Name,VolumeSerialNumber,VolumeName,Description /format:textvaluelist.xsl |sed 's#\r##g' |awk -F "=" '$1 {print toupper($1) "=" "\"" $2 "\""}')"
#eval "$VARS"
. $SDIR/drive.sh
RID="$DRIVE.$VOLUMESERIALNUMBER.$VOLUMENAME.$DRIVETYPE.$FILESYSTEM/.bkit/$BPATH"

MANIFESTDIR=$SDIR/cache/$RID
mkdir -p "$MANIFESTDIR"
MANIFESTFILE=$MANIFESTDIR/manifest
if [[ $FORCE || ! -f "$MANIFESTFILE" || $UPDATE && $(find "$MANIFESTFILE" -mtime +30) ]] 
then
  echo Get manifest of $BACKUPDIR
  find "$BUDIR" -type f -printf "%P:%s\n" |LC_ALL=C sort > "$MANIFESTFILE"
  echo Got manifest of $BACKUPDIR
else
  echo Nothing to do at this time for directory $BACKUPDIR
fi
