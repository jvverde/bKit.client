#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"								#Full DIR
[[ $1 == '-log' ]] && shift && exec 1>"$1" 2>&1 && shift

BACKUPDIR="$1"

die() { echo -e "$@"; exit 1; }

[[ $BACKUPDIR == /dev/* ]] && { 

	DEV=$(readlink -ne $BACKUPDIR)
	
	MOUNT=$(lsblk -lno MOUNTPOINT $DEV)

	[[ -z $MOUNT ]] && MOUNT=/tmp/bkit-$(date +%s) && mkdir -pv $MOUNT && { 
		mount -o ro $DEV  $MOUNT || die Cannot mount $DEV on $MOUNT
		trap "umount $DEV && rm -rvf $MOUNT" EXIT 
	} 
	ROOT=$MOUNT
	BPATH=""
} || die mais logo vejo isso
echo ROOT $ROOT
echo BAPTH $BPATH

. $SDIR/drive.sh $DEV

RID="_.$VOLUMESERIALNUMBER.$VOLUMENAME.$DRIVETYPE.$FILESYSTEM"
CONF="$SDIR/conf/conf.init"
[[ -f $CONF ]] || die Cannot found configuration file at $CONF
source $CONF

type rsync 2>/dev/null 1>&2 || die rsync is not on path


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
		rsync "$@" 2>&1 
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

CLEAN=" --delete --force --delete-excluded --ignore-non-existing --ignore-existing"
FMT_QUERY='--out-format=%i|%n|%L|/%f'

trap '' SIGPIPE

let NJOBS=1+$(nproc)
wait4jobs(){
	LIMIT=${1-$NJOBS}
	while list=($(jobs -rp)) && ((${#list[*]} > $LIMIT))
	do
		echo Wait for jobs "${list[@]}" to finish
		wait -n
	done
}

update_file(){
	dorsync -tiz --inplace $PERM $PASS $FMT "$@"&
	wait4jobs
}

RUNDIR=$SDIR/run
HLIST=$SDIR/run/hardlink-list
DLIST=$SDIR/run/dirs-list
mkdir -p $RUNDIR
postpone_hl(){ 
	(IFS=$'\n' && echo "$*" ) >&99
}
postpone_dir(){ 
	(IFS=$'\n' && echo "$*" ) >&98
}
exec 99>"$HLIST"
update_hardlinks(){
	dorsync --archive --hard-links --relative --files-from="$HLIST" --itemize-changes $PERM $PASS $FMT "$@"
	wait4jobs
	exec 99>"$HLIST"
}
exec 98>"$DLIST"
update_dirs(){
	dorsync --archive --hard-links --relative --files-from="$DLIST" --itemize-changes $PERM $PASS $FMT "$@"
	wait4jobs
	exec 98>"$DLIST"
}

backup(){
	BASE=$1
	SRC="$1/./$2"
	DST=$3
	[[ -e $SRC ]] || ! echo $SRC does not exist || continue
	TYPE=${DST##*/}
	unset HLINK
	while IFS='|' read -r I FILE LINK FULLPATH
	do
		echo miss "$I|$FILE|$LINK|$FULLPATH"
		FILE=$(echo $FILE|sed -e 's#/$##')  #only to avoid sync file in a directory directly on /current

		[[ $I =~ ^[c.][dLDS] && $FILE != '.' ]] && postpone_dir "$FILE" && continue

		[[ $I =~ ^[\<.]f ]] &&
			HASH=$(sha512sum -b "$FULLPATH" | cut -d' ' -f1 | perl -lane '@a=split //,$F[0]; print join(q|/|,@a[0..3],$F[0])') &&
			update_file "$FULLPATH" "$BACKUPURL/$RID/@manifest/$HASH/$TYPE/$FILE" && continue 

		[[ $I =~ ^h[fL] && $LINK =~ =\> ]] && LINK=$(echo $LINK|sed -E 's/\s*=>\s*//') &&  postpone_hl "$LINK" "$FILE" && continue

		[[ $I =~ ^h[fL] && ! $LINK =~ =\> ]] && HLINK=missing

	done < <(dorsync --dry-run --archive --hard-links --relative --itemize-changes $PERM $PASS $EXC $FMT_QUERY "$SRC" "$DST")
	wait4jobs 0
	update_hardlinks "$BASE/" "$DST"
	wait4jobs 0
	update_dirs	"$BASE/" "$DST"
}
clean(){
	BASE=$1
	SRC="$1/./$2"
	DST=$3
	[[ -e $SRC ]] || ! echo $SRC does not exist || continue
	dorsync -riHDR $CLEAN $PERM $PASS $FMT "$SRC" "$DST" #clean deleted files
}
snapshot(){
	dorsync --dry-run --dirs --ignore-non-existing --ignore-existing $PASS "$ROOT/./" "$BACKUPURL/$RID/@snap"
}

snapshot																		#first create a snapshot

backup "$ROOT" "$BPATH" "$BACKUPURL/$RID/@current/data"							#backup data

[[ -n $HLINK ]] && backup "$ROOT" "$BPATH" "$BACKUPURL/$RID/@current/data"		#if missing HARDLINK then do it again

clean "$ROOT" "$BPATH" "$BACKUPURL/$RID/@current/data" 							#clean deleted files


wait4jobs 0

 
echo Backup of $BACKUPDIR done at $(date -R)
