#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR=$(cygpath "$(dirname "$(readlink -f "$0")")")	#Full DIR
[[ $1 == '-log' ]] && shift && exec 1>"$1" 2>&1 && shift

BACKUPDIR="$1"

die() { echo -e "$@"; exit 1; }

[[ $BACKUPDIR =~ ^[a-zA-Z]: ]] || die "Usage:\n\t$0 Drive:\\backupDir mapDriveLetter:"

DRIVE=${BACKUPDIR%%:*}
DRIVE=${DRIVE^^}
MAPDRIVE="${2:-$DRIVE:}"

[[ $MAPDRIVE =~ ^[a-zA-Z]:$ ]] || die "Usage:\n\t$0 Drive:\\backupDir mapDriveLetter:"

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

#FMT='--out-format="%p|%t|%o|%i|%b|%l|%f"'
FMT='--out-format="%o|%i|%f|%c|%b|%l|%t"'
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

INPLACE="--inplace"
CLEAN=" --delete --force --delete-excluded --ignore-non-existing --ignore-existing"
FMT_QUERY='--out-format=%i|%n|%L|/%f'

trap '' SIGPIPE

let NPROC=3*$(nproc)
wait4jobs(){
  while list=($(jobs -rp)) && ((${#list[*]} > $NPROC))
  do
    echo wait for jobs "${list[@]}" to finish
    wait -n
  done
}
backup(){
	DIR=$1
	[[ -e $DIR ]] || ! echo $DIR does not exist || continue
	BASE="${DIR%%/./*}"
	while IFS='|' read -r I FILE LINK FULLPATH
	do
		echo miss "$I|$FILE|$LINK|$FULLPATH"
		FILE=$(echo $FILE|sed -e 's/"/\\"/g' -e "s/'/\\'/g" -e 's#/$##')

		[[ $I =~ ^[c.][dLDS] && $FILE != '.' ]] && {
			dorsync -dltDRi $PERM $PASS $FMT "$BASE/./$FILE" "$BACKUPURL/$RID/current/"&
      wait4jobs && continue
    }

		[[ $I =~ ^[\<.]f ]] && {
			HASH=$(sha512sum -b "$FULLPATH" | cut -d' ' -f1 | perl -lane '@a=split //,$F[0]; print join(q|/|,@a[0..3],$F[0])')
			dorsync -tiz $INPLACE $PERM $PASS $FMT "$FULLPATH" "$BACKUPURL/$RID/@manifest/$HASH/$FILE"& 
      wait4jobs && continue
    }

		[[ $I =~ ^hf && $LINK =~ =\> ]] && LINK=$(echo $LINK|sed -E 's/\s*=>\s*//') &&  {
			HASH=$(sha512sum -b "$FULLPATH" | cut -d' ' -f1 | perl -lane '@a=split //,$F[0]; print join(q|/|,@a[0..3],$F[0])') 
			dorsync -tHRi $PERM $PASS $FMT "$BASE/./$LINK" "$BASE/./$FILE" "$BACKUPURL/$RID/current/"&
      wait4jobs && continue
		}	
	done

}

backup "$ROOT/./$BPATH" < <(dorsync -narilHDR $PASS $EXC $FMT_QUERY "$ROOT/./$BPATH" "$BACKUPURL/$RID/snap/")

"$SDIR"/acls.sh "$BACKUPDIR" 2>&1 |  xargs -d '\n' -I{} echo Acls: {}

backup "$METADATADIR/./.bkit/$BPATH" < <(dorsync -narilHDR $PASS $EXC $FMT_QUERY "$METADATADIR/./.bkit/$BPATH" "$BACKUPURL/$RID/current/")

dorsync -riHDR $CLEAN $PERM $PASS $FMT "$ROOT/./$BPATH" "$BACKUPURL/$RID/current/"
 
echo Backup of $BACKUPDIR done at $(date -R)
