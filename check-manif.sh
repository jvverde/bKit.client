#!/bin/bash
SDIR=$(dirname "$(readlink -f "$0")")	#Full DIR
BACKUPDIR="$1"
die() { echo -e "$@"; exit 1; }

[[ $BACKUPDIR =~ ^[a-zA-Z]: ]]  || die "Usage:\n\t$0 Drive:\\full-path-of-backup-dir"

BUDIR="$(cygpath "$BACKUPDIR")"

[[ -d "$BUDIR" ]] || die "The directory $BACKUPDIR ($BUDIR)doesn't exist"

DRIVE=${BACKUPDIR%%:*}
DRIVE=${DRIVE^^}
BPATH=${BACKUPDIR#*:}
BPATH=${BPATH#*\\}
VARS="$(wmic logicaldisk WHERE "Name='$DRIVE:'" GET Name,VolumeSerialNumber,VolumeName,Description /format:textvaluelist.xsl |sed 's#\r##g' |awk -F "=" '$1 {print toupper($1) "=" "\"" $2 "\""}')"
eval "$VARS"
RID="$DRIVE.$VOLUMESERIALNUMBER.$VOLUMENAME ($DESCRIPTION).${BPATH//\\/.}"
mkdir -p "$SDIR/cache"
MANIFPATH="$SDIR/cache/$RID.man"
if [[ ! -f "$MANIFPATH" || $(find "$MANIFPATH" -mmin +120) ]] 
then
  echo Get manifest of $BACKUPDIR
  find "$BUDIR" -type f -printf "%P\n" > "$MANIFPATH"
  RSYNC=$(find $DIR -type f -name "rsync.exe" -print | head -n 1)
  [[ -f $RSYNC ]] || die "Rsync.exe not found"
  echo $RSYNC
fi
