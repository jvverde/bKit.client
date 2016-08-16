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
#"$SDIR"/acls.sh "$BACKUPDIR" 2>&1 |  xargs -d '\n' -I{} echo Acls: {}
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
PERM="--perms --acls --owner --group --super --numeric-ids"
OPTIONS=" --inplace --delete-delay --force --delete-excluded --stats --fuzzy"
#FOPTIONS=" --stats --fuzzy"
mkdir -p $SDIR/run #jus in case

dorsync(){
	CNT=1000
	while true
	do
		(( --CNT < 0 )) && echo "I'm tired of trying" && break 
		${RSYNC} "$@" 2>&1 
		ret=$?
		case $ret in
			0) break 									#this is a success
			;;
			5|10|12|30|35)
				DELAY=$((1 + RANDOM % 60))
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
}

trap '' SIGPIPE
for DIR in "$ROOT/./$BPATH" #"$METADATADIR/./.bkit/$BPATH"
do
	[[ -e $DIR ]] || ! echo $DIR does not exist || continue
	BASE="${DIR%%/./*}"
	RE=$(echo $BASE|sed 's/[^-a-zA-Z0-9_]/\\&/g')
	dorsync -narilDHR $PASS $EXC "$DIR" "$BACKUPURL/$RID/current/" |
	while IFS= read -r MISSING
	do
		echo miss $MISSING
			#echo dorsync -dltDRi $PERM $PASS $FMT "$BASE/./$ENTRY" "$BACKUPURL/$RID/current/"

		RESOURCE=$(echo $MISSING |grep '^[c.][dD]' | cut -d' ' -f2-| sed -e 's/"/\\"/g' -e "s/'/\\'/g" -e 's#/$##') 
		[[ -n $RESOURCE ]] && dorsync -dltDRi $PERM $PASS $FMT "$BASE/./$RESOURCE" "$BACKUPURL/$RID/current/"
		RESOURCE=$(echo $MISSING |grep '^[c.][S]' | cut -d' ' -f2-| sed -e 's/"/\\"/g' -e "s/'/\\'/g" -e 's#/$##') 
		[[ -n $RESOURCE ]] && dorsync -tDRi --super $PERM $PASS $FMT "$BASE/./$RESOURCE" "$BACKUPURL/$RID/current/"
		#RESOURCE=$(echo $MISSING |grep '^[c.]L' | cut -d' ' -f2-| sed -e 's/"/\\"/g' -e "s/'/\\'/g" -e 's#/$##') 
		#[[ -n $RESOURCE ]] && (dorsync -dltRi $PERM $PASS $FMT "$BASE/./$RESOURCE" "$BACKUPURL/$RID/current/")
		#continue
		RESOURCE=$(echo $MISSING | grep '^[<.]f'| cut -d' ' -f2-| sed -e 's/"/\\"/g' -e "s/'/\\'/g")
		[[ -n $RESOURCE ]] && sha512sum -b "$BASE/$RESOURCE" |( 
			read -r HASH FILE
			SRC="$BASE/$RESOURCE"
			#echo Send hash $HASH for file $SRC 
			DST="$(echo $HASH | perl -lane '@a=split //,$F[0]; print join(q|/|,@a[0..3],$F[0])')/$RESOURCE"
			dorsync -ltiz $PERM $PASS $FMT "$SRC" "$BACKUPURL/$RID/@manifest/$DST"
		)
	done
done
exit 
if [[ -e "$METADATADIR/./.bkit/$BPATH" ]] 
then 
  ${RSYNC} -rlitzvvhHDR $OPTIONS $PERM $PASS $FMT $EXC "$ROOT/./$BPATH" "$METADATADIR/./.bkit/$BPATH" "$BACKUPURL/$RID/current/" 2>&1 
else
  ${RSYNC} -rlitzvvhHDR $OPTIONS $PERM $PASS $FMT $EXC "$ROOT/./$BPATH" "$BACKUPURL/$RID/current/" 2>&1 
fi
  
echo Backup of $BACKUPDIR done at $(date -R)
