#!/bin/bash
SDIR=$(dirname "$(readlink -f "$0")")	#Full DIR
BACKUPDIR="$1"
! [[ $BACKUPDIR =~ ^[a-zA-Z]: ]] && echo -e "Usage:\n\t$0 Drive:\\full-path-of-backup-dir" && exit 1
BUDIR="$(cygpath "$BACKUPDIR")"

! [[ -d "$BUDIR" ]] && echo "The directory $BACKUPDIR ($BUDIR)doesn't exist" && exit 1

DRIVE=${BACKUPDIR%%:*}
DRIVE=${DRIVE^^}
BPATH=${BACKUPDIR#*:}
BPATH=${BPATH#*\\}
VARS="$(wmic logicaldisk WHERE "Name='$DRIVE:'" GET Name,VolumeSerialNumber,VolumeName,Description /format:textvaluelist.xsl |sed 's#\r##g' |awk -F "=" '$1 {print toupper($1) "=" "\"" $2 "\""}')"
eval "$VARS"
RID="$DRIVE.$VOLUMESERIALNUMBER.$VOLUMENAME ($DESCRIPTION).${BPATH//\\/.}"
mkdir -p "$SDIR/cache"
MANIFPATH="$SDIR/cache/$RID.man"
if [[ ! -f "$MANIFPATH" || $(find "$MANIFPATH" -mmin +1) ]] 
then
  echo Get manifest of $BACKUPDIR
  find "$BUDIR" -type f -printf "%P\n" > "$MANIFPATH"
  RSYNC=$(find $SDIR -type f -name "rsync.exe" -print | head -n 1)
fi


echo $RSYNC
exit
${RSYNC} -rltvvhR --inplace --stats ${MANIFPATH}/./ rsync://admin\@${SERVER}:${port}/${section}/win/${domain}/${name}/${uuid}

[[ "$?" -ne "0" ]] && echo "Exit value of rsync is non null: $?" && exit 1

