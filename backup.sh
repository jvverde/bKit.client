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
mkdir -p $SDIR/run 										#jusy in case

dorsync(){
	CNT=1000
	while true
	do
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
			23|24)
				echo Rsync returns a non null valor ($ret) but I will ignore it 
				break
			;;
		esac
		(( --CNT < 0 )) && echo "I'm tired of trying" && break 
	done
}

CLEAN=" --delete --force --delete-excluded --ignore-non-existing --ignore-existing"
FMT_QUERY='--out-format=%i|%n|%L|/%f'

trap '' SIGPIPE

let NJOBS=3*$(nproc)
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
HLIST=$SDIR/run/hardlink-list.$$
DLIST=$SDIR/run/update-list.$$
mkdir -p $RUNDIR
postpone_hl(){ 
	(IFS=$'\n' && echo "$*" ) >&99
}
postpone_update(){ 
	(IFS=$'\n' && echo "$*" ) >&98
}
exec 99>"$HLIST"
update_hardlinks(){
	dorsync --archive --hard-links --relative --files-from="$HLIST" --itemize-changes $PERM $PASS $FMT "$@"
	wait4jobs
	exec 99>/dev/null
	rm -fv "$HLIST"
}
exec 98>"$DLIST"
update_dirs(){
	dorsync --archive --relative --files-from="$DLIST" --itemize-changes $PERM $PASS $FMT "$@"
	wait4jobs
	exec 98>/dev/null
	rm -fv "$DLIST"
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
		echo miss "$I|$FILE|$LINK"
		
		FILE=${FILE%/}	#remove trailing backslash in order to avoid sync files in a directory directly
		
		#if a directory, symlink, device or special
		[[ $I =~ ^[c.][dLDS] && $FILE != '.' ]] && postpone_update "$FILE" && continue
		
		#if file only need to be update
		#This is dangerous and could ends in transfer (get out ou sync) new data if file changes meanwhile [[ $I =~ ^[.]f ]] && postpone_update "$FILE" && continue
		
		#this is the main (and most costly) case. A file, or part of it, need to be transfer
		[[ $I =~ ^[.\<]f ]] &&
			HASH=$(sha512sum -b "$FULLPATH" | cut -d' ' -f1 | perl -lane '@a=split //,$F[0]; print join(q|/|,@a[0..3],$F[0])') &&
			update_file "$FULLPATH" "$BACKUPURL/$RID/@manifest/$HASH/$TYPE/$FILE" && continue 
		
		#if a hard links (to file or to symlink)
		[[ $I =~ ^h[fL] && $LINK =~ =\> ]] && LINK=$(echo $LINK|sed -E 's/\s*=>\s*//') &&  postpone_hl "$LINK" "$FILE" && continue
		
		#there are situations where the rsync don't know yet the target of a hardlink, so we need to label it to ran gain later
		[[ $I =~ ^h[fL] && ! $LINK =~ =\> ]] && HLINK=missing && continue

		echo Is something else
		
	done < <(dorsync --dry-run --archive --hard-links --relative --itemize-changes $PERM $PASS $EXC $FMT_QUERY "$SRC" "$DST")
	wait4jobs 0
	update_hardlinks "$BASE" "$DST"
	wait4jobs 0
	update_dirs	"$BASE" "$DST"
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

"$SDIR"/acls.sh "$BACKUPDIR" 2>&1 |  xargs -d '\n' -I{} echo Acls: {}			#get ACLS

backup "$METADATADIR" ".bkit/$BPATH" "$BACKUPURL/$RID/@current/metadata"		#backup metadata

clean "$METADATADIR" ".bkit/$BPATH" "$BACKUPURL/$RID/@current/metadata" 		#clean deleted files

wait4jobs 0

 
echo Backup of $BACKUPDIR done at $(date -R)
