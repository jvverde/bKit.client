#!/bin/bash
SDIR=$(dirname "$(readlink -f "$0")")	#Full DIR
BACKUPDIR="$1"

die() { echo -e "$@"; exit 1; }

[[ $BACKUPDIR =~ ^[a-zA-Z]: ]]  || die "Usage:\n\t$0 Drive:\\full-path-of-backup-dir"

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
RID="$DRIVE.$VOLUMESERIALNUMBER.${VOLUMENAME:-_}.$DESCRIPTION.${BPATH//\\/.}"
MANIFESTDIR=$SDIR/cache
RUNDIR=$SDIR/run
mkdir -p "$MANIFESTDIR"
mkdir -p "$RUNDIR"
W=$RUNDIR/W
R=$RUNDIR/R
[[ -p $W ]] || mkfifo $W  || die cannot create the fifo $W
[[ -p $R ]] || mkfifo $R  || die cannot create the fifo $R
MANIFESTFILE=$MANIFESTDIR/$RID.manifest
if [[ ! -f "$MANIFESTFILE" || $(find "$MANIFESTFILE" -mmin +0) ]] 
then
  echo Get manifest of $BACKUPDIR
  find "$BUDIR" -type f -printf "%P\n" > "$MANIFESTFILE"
  RSYNC=$(find "$SDIR" -type f -name "rsync.exe" -print | head -n 1)
  PERL=$(find "$SDIR" -type f -name "perl.exe" -print | head -n 1)
  [[ -f $RSYNC ]] || die Rsync.exe not found
  CONF="$SDIR/conf/conf.init"
  [[ -f $CONF ]] || die Cannot found configuration file at $CONF
  source $CONF
  
  EXEC="$RSYNC --password-file="$SDIR/conf/pass.txt" -rlitzvvhR --chmod=D750,F640 --inplace --fuzzy --stats ${MANIFESTDIR}/./ $MANIFURL/"
  $EXEC
fi
