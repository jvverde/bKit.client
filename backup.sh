#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR=$(cygpath "$(dirname "$(readlink -f "$0")")")	#Full DIR
[[ $1 == '-log' ]] && shift && exec 1>$1 2>&1 && shift

BACKUPDIR="$1"

die() { echo -e "$@"; exit 1; }

[[ $BACKUPDIR =~ ^[a-zA-Z]: ]] || die "Usage:\n\t$0 Drive:\\backupDir mapDriveLetter:"

DRIVE=${BACKUPDIR%%:*}
DRIVE=${DRIVE^^}
MAPDRIVE="${2:-$DRIVE:}"

[[ $MAPDRIVE =~ ^[a-zA-Z]:$ ]] || die "Usage:\n\t$0 Drive:\\backupDir mapDriveLetter:"

echo Backup $1 on mapped Drive $2
#$SDIR/acls.sh $BACKUPDIR 2>&1 |  xargs -d '\n' -I{} echo Acls: {}
echo 'ACLs done'


BPATH=${BACKUPDIR#*:} #remove anything before character ':' inclusive
BPATH=${BPATH#*\\}    #remove anything before character '\' inclusive
[[ -n $BPATH ]] && BPATH="$(cygpath "$BPATH")"

ROOT="$(cygpath "$MAPDRIVE")"
BUDIR=$ROOT/$BPATH

[[ -d "$BUDIR" ]] || die "The mapped directory $BUDIR doesn't exist"

. $SDIR/drive.sh
[[ $DRIVETYPE == *"Ram Disk"* ]] && die This drive is a RAM Disk 
RID="$DRIVE.$VOLUMESERIALNUMBER.$VOLUMENAME.$DRIVETYPE.$FILESYSTEM"
METADATADIR=$SDIR/cache/$RID
CONF="$SDIR/conf/conf.init"
[[ -f $CONF ]] || die Cannot found configuration file at $CONF
source $CONF

RSYNC=$(find "$SDIR/3rd-party" -type f -name "rsync.exe" -print | head -n 1)
[[ -f $RSYNC ]] || die "Rsync.exe not found"

FMT='--out-format="%p|%t|%o|%i|%b|%l|%f"'
EXC="--exclude-from=$SDIR/conf/excludes.txt"
PASS="--password-file=$SDIR/conf/pass.txt"
PERM="--acls --owner --group --super --numeric-ids"
OPTIONS=" --inplace --delete-delay --force --delete-excluded --stats --fuzzy"
#FOPTIONS=" --stats --fuzzy"


RRE=$(echo $ROOT|sed 's/[^-a-zA-Z0-9_]/\\&/g')
find $BUDIR -type f | 
xargs -I{} sha512sum -b {} | 
sed -e 's/"/\\"/g' -e "s/'/\\'/g" |
while read HASH FILE
do
  FILE="$(echo $FILE|sed "s#^*$RRE/##")"
  SRC="$ROOT/./$FILE"
  DST="$(echo $HASH | perl -lane '@a=split //,$F[0]; print join(q|/|,@a[0..3],$F[0])')/$FILE"
  echo $RSYNC -ltizvvhR $PASS $FMT $SRC $BACKUPURL/$RID/manifest/$DST
done  
exit; 

{
	CNT=60
  mkdir -p $SDIR/run #jus in case
	while true
	do
		(( --CNT < 0 )) && echo "I'm tired of waiting" && break 
    {
      flock -x 9
      ${RSYNC} -rlitzvvhR $OPTIONS $PERM $PASS $FMT $EXC $ROOT/./$BPATH $METADATADIR/./.bkit/$BPATH $BACKUPURL/$RID/current/ 2>&1 
      ret=$?
      [ $ret -eq 0 ] && sleep 120 #be nice to others, by don't release the lock immediately
    } 9> $SDIR/run/.lock
		case $ret in
			0) break ;;
			10|12)
				echo "Fail with Error $ret. Maybe the manifest wasn't sent yet. I will sent it again"
				$SDIR/send-manifest.sh $BACKUPDIR 2>&1 | xargs -d '\n' -I{} echo Send-manifest: '{}'
				;;
			5|30|35)
				DELAY=$((120 + RANDOM % 480))
				echo Received error $ret. Try again in $DELAY seconds
				sleep $DELAY
				echo Try again now
				;;
			*)
				echo Fail to backup. Exit value of rsync is non null: $ret 
				exit 1
				;;
		esac
	done
} > >(xargs -d '\n' -I{} echo Rsync: {})


echo Backup of $BACKUPDIR done at $(date -R)
