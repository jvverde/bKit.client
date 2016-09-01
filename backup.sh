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

STARTDIR=${BACKUPDIR#*:}              #remove anything before character ':' inclusive
STARTDIR=${STARTDIR#*\\}              #remove anything before character '\' inclusive
[[ -n $STARTDIR ]] && STARTDIR="$(cygpath "$STARTDIR")"

ROOT="$(cygpath "$MAPDRIVE")"
FULLPATHDIR="$ROOT/$STARTDIR"

[[ -d "$FULLPATHDIR" ]] || die "The mapped directory $FULLPATHDIR doesn't exist"

. $SDIR/drive.sh $DRIVE
[[ $DRIVETYPE == *"Ram Disk"* ]] && die This drive is a RAM Disk 
RID="$DRIVE.$VOLUMESERIALNUMBER.$VOLUMENAME.$DRIVETYPE.$FILESYSTEM"
METADATADIR=$SDIR/cache/$RID
CONF="$SDIR/conf/conf.init"
[[ -f $CONF ]] || die Cannot found configuration file at $CONF
source $CONF

type rsync || die Cannot find rsync

trap '' SIGPIPE

dorsync(){
	CNT=1000
	while true
	do
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
			23|24)
				echo Rsync returns a non null value "'$ret'" but I will ignore it 
				break
			;;
			*)
				echo Fail to backup. Exit value of rsync is non null: $ret 
				exit 1
			;;
		esac
		(( --CNT < 0 )) && echo "I'm tired of trying" && break 
	done
}


let NJOBS=$(nproc)
wait4jobs(){
	LIMIT=${1-$NJOBS}
	while list=($(jobs -rp)) && ((${#list[*]} > $LIMIT))
	do
		echo Wait for jobs "${list[@]}" to finish
		wait -n
	done
}

RUNDIR=$SDIR/run
FLIST=$SDIR/run/file-list.$$
HLIST=$SDIR/run/hl-list.$$
DLIST=$SDIR/run/dir-list.$$
mkdir -p $RUNDIR


clear_lists(){
	exec 99>"$HLIST"
	exec 98>"$DLIST"
	exec 97>"$FLIST"
}
remove_lists(){
	rm -rf "$HLIST" "$DLIST"
}
postpone_file(){ 
	(IFS=$'\n' && echo "$*" ) >&97
}
postpone_hl(){ 
	(IFS=$'\n' && echo "$*" ) >&99
}
postpone_update(){ 
	(IFS=$'\n' && echo "$*" ) >&98
}

#FMT='--out-format="%p|%t|%o|%i|%b|%l|%f"'
FMT='--out-format="%o|%i|%f|%c|%b|%l|%t"'
EXC="--exclude-from=$SDIR/conf/excludes.txt"
PASS="--password-file=$SDIR/conf/pass.txt"
PERM="--perms --acls --owner --group --super --numeric-ids"
OPTIONS=" --inplace --delete-delay --force --delete-excluded --stats --fuzzy"
#FOPTIONS=" --stats --fuzzy"
CLEAN=" --delete --force --delete-excluded --ignore-non-existing --ignore-existing"
FMT_QUERY='--out-format=%i|%n|%L|/%f'
FMT_QUERY2='--out-format=%i|%n|%L|/%f|%l|%M'

update_hardlinks(){
	wait4jobs 0
	dorsync --archive --hard-links --relative --files-from="$HLIST" --itemize-changes $PERM $PASS $FMT "$@"
}
update_dirs(){
	wait4jobs 0
	dorsync --archive --relative --files-from="$DLIST" --itemize-changes $PERM $PASS $FMT "$@"
}
update_file(){
	dorsync -tiz --inplace $PERM $PASS $FMT "$@"
}
update_files(){
  
}

backup(){
	BASE=$1
	SRC="$1/./$2"
	DST=$3
	[[ -e $SRC ]] || ! echo $SRC does not exist || continue
	TYPE=${DST##*/}
	unset HLINK
	clear_lists
	while IFS='|' read -r I FILE LINK FULLPATH LEN MODIFICATION
	do
		echo miss "$I|$FILE|$LINK|$LEN"
		
		FILE=${FILE%/}	#remove trailing backslash in order to avoid sync files in a directory directly
		
		#if a directory, symlink, device or special
		[[ $I =~ ^[c.][dLDS] && $FILE != '.' ]] && postpone_update "$FILE" && continue
		
		#if file only need to be update
		#This is dangerous and could ends in transfer (get out ou sync) new data if file changes meanwhile [[ $I =~ ^[.]f ]] && postpone_update "$FILE" && continue
		
		#this is the main (and most costly) case. A file, or part of it, need to be transfer
		[[ $I =~ ^[.\<]f ]] && {
      postpone_file "$FILE"
    }
      #SIZE=$(stat --format="%s" "$FULLPATH") && echo SIZE=$SIZE && continue
			##HASH=$(sha512sum -b "postpone_file" | cut -d' ' -f1 | perl -lane '@a=split //,$F[0]; print join(q|/|,@a[0..3],$F[0])') &&
			#update_file "$FULLPATH" "$BACKUPURL/$RID/@manifest/$HASH/$TYPE/$FILE" && continue 
		
		#if a hard links (to file or to symlink)
		[[ $I =~ ^h[fL] && $LINK =~ =\> ]] && LINK=$(echo $LINK|sed -E 's/\s*=>\s*//') &&  postpone_hl "$LINK" "$FILE" && continue
		
		#there are situations where the rsync don't know yet the target of a hardlink, so we need to label it to run again later
		[[ $I =~ ^h[fL] && ! $LINK =~ =\> ]] && HLINK=missing && continue

		echo Is something else
		
	done < <(dorsync --dry-run --archive --hard-links --relative --itemize-changes $PERM $PASS $EXC $FMT_QUERY2 "$SRC" "$DST")
  exit
  update_files "$BASE" "$BACKUPURL/$RID/@manifest/$TYPE"
	update_hardlinks "$BASE" "$DST"
	update_dirs	"$BASE" "$DST"
	remove_lists
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

NEW=$(bash ./hash.sh -f "$FULLPATHDIR")
[[ -e $NEW ]] && update_file "$NEW" "$BACKUPURL/$RID/@manifest/data/$STARTDIR/"
exit
#clear_lists
#hash_file&

snapshot																		#first create a snapshot

backup "$ROOT" "$STARTDIR" "$BACKUPURL/$RID/@current/data"							#backup data

exit

[[ -n $HLINK ]] && backup "$ROOT" "$STARTDIR" "$BACKUPURL/$RID/@current/data"		#if missing HARDLINK then do it again

clean "$ROOT" "$STARTDIR" "$BACKUPURL/$RID/@current/data" 							#clean deleted files

"$SDIR"/acls.sh "$BACKUPDIR" 2>&1 |  xargs -d '\n' -I{} echo Acls: {}			#get ACLS

backup "$METADATADIR" ".bkit/$STARTDIR" "$BACKUPURL/$RID/@current/metadata"		#backup metadata

clean "$METADATADIR" ".bkit/$STARTDIR" "$BACKUPURL/$RID/@current/metadata" 		#clean deleted files

wait4jobs 0
 
echo Backup of $BACKUPDIR done at $(date -R)
