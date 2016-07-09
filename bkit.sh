#!/bin/bash
SDIR=$(dirname "$(readlink -f "$0")")	#Full DIR
BACKUPDIR="$1"

die() { echo "$@"; exit 1; }

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
RID="$DRIVE.$VOLUMESERIALNUMBER.${VOLUMENAME:-_}.$DESCRIPTION/${BPATH}"


CONF="$SDIR/conf/conf.init"
[[ -f $CONF ]] || die Cannot found configuration file at $CONF
source $CONF

RSYNC=$(find $SDIR -type f -name "rsync.exe" -print | head -n 1)
[[ -f $RSYNC ]] || die "Rsync.exe not found"

FMT='--out-format="%p|%t|%o|%i|%b|%l|%f"'
EXC="--exclude-from=$SDIR/conf/excludes.txt"
OPTIONS="--chmod=D750,F640 --inplace --delete-delay --force --delete-excluded --stats --fuzzy"
${RSYNC} -rlitzvvhR $OPTIONS $FMT $EXC $SOURCE $BACKUPURL/$DRIVE/current

[[ "$?" -ne 0 ]] && echo "Exit value of rsync is non null: $?" && exit 1
