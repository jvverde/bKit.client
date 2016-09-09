#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR
[[ $1 == '-log' ]] && shift && exec 1>"$1" 2>&1 && shift
[[ $1 == '-f' ]] && FSW='-f' && shift				#get -f option if present and set f switch

exists() { type "$1" >/dev/null 2>&1;}
die() { echo -e "$@">&2; exit 1; }

[[ -n $1 ]] || die "Usage:\n\t$0 path [mapdrive]"
[[ -d $1 ]] || die Cannot find directory $1

BACKUPDIR="$1"

exists cygpath && BACKUPDIR=$(cygpath "$1") && SDIR=$(cygpath "$SDIR")

BACKUPDIR=$(readlink -ne "$BACKUPDIR")

[[ $BACKUPDIR == /dev/* ]] && { 
	DEV=$BACKUPDIR
	MOUNT=$(lsblk -lno MOUNTPOINT $DEV)
	[[ -z $MOUNT ]] && MOUNT=/tmp/bkit-$(date +%s) && mkdir -pv $MOUNT && {
		mount -o ro $DEV  $MOUNT || die Cannot mount $DEV on $MOUNT
		trap "umount $DEV && rm -rvf $MOUNT" EXIT
	}
	ROOT=$MOUNT
	STARTDIR=""
} || {
	MOUNT=$(stat -c%m "$BACKUPDIR")
	STARTDIR=${BACKUPDIR#$MOUNT}
	STARTDIR=${STARTDIR#/}	
	DEV=$(df --output=source "$MOUNT"|tail -1)
	ROOT=$MOUNT
	[[ -n $2 ]] && exists cygpath && ROOT=$(cygpath "$2")
}
BACKUPDIR="$ROOT/$STARTDIR"
[[ -d $BACKUPDIR ]] || die Cannot find directory $BACKUPDIR

source "$SDIR/drive.sh" "$DEV"

[[ $DRIVETYPE == *"Ram Disk"* ]] && die This drive is a RAM Disk 
#compute Remote Volume ID
RVID="${DRIVE:-_}.${VOLUMESERIALNUMBER:-_}.${VOLUMENAME:-_}.${DRIVETYPE:-_}.${FILESYSTEM:-_}"
CONF="$SDIR/conf/conf.init"
[[ -f $CONF ]] || die Cannot found configuration file at $CONF
source $CONF

exists rsync || die Cannot find rsync

trap '' SIGPIPE

dorsync(){
	local RETRIES=1000
	while true
	do
		rsync --one-file-system "$@" 2>&1 
		local ret=$?
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
		(( --RETRIES < 0 )) && echo "I'm tired of trying" && break 
	done
}

RUNDIR=$SDIR/run
mkdir -p $RUNDIR
FLIST=$RUNDIR/file-list.$$
HLIST=$RUNDIR/hl-list.$$
DLIST=$RUNDIR/dir-list.$$


set_postpone_files(){
	exec 99>"$HLIST"
	exec 98>"$DLIST"
	exec 97>"$FLIST"
}
remove_postpone_files(){
	rm -rfv "$HLIST" "$DLIST" "$FLIST"
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

FMT='--out-format="%o|%i|%f|%c|%b|%l|%t"'
EXC="--exclude-from=$SDIR/conf/excludes.txt"
PASS="--password-file=$SDIR/conf/pass.txt"
PERM="--perms --acls --owner --group --super --numeric-ids"
OPTIONS=" --inplace --delete-delay --force --delete-excluded --stats --fuzzy"
CLEAN="--delete --force --delete-excluded --ignore-non-existing --ignore-existing"
#CLEAN="--delete --force --delete-excluded"
FMT_QUERY='--out-format=%i|%n|%L|/%f'
FMT_QUERY2='--out-format=%i|%n|%L|/%f|%l'
FMT_QUERY3='--out-format=%i|%n'

update_hardlinks(){
	dorsync --archive --hard-links --relative --files-from="$HLIST" --itemize-changes $PERM $PASS $FMT "$@"
}
update_dirs(){
	dorsync --archive --relative --files-from="$DLIST" --itemize-changes $PERM $PASS $FMT "$@"
}
update_file(){
	dorsync -tiz --inplace $PERM $PASS $FMT "$@"
}


backup(){
	local BASE=$1
	local SRC="$1/./$2"
	local DST=$3
	[[ -e $SRC ]] || ! echo $SRC does not exists || return 1
	[[ -d $SRC ]] && local HASHDB=$(bash $SDIR/hash.sh -b "$SRC")
	local TYPE=${DST##*/}
	unset HLINK
	set_postpone_files
	while IFS='|' read -r I FILE LINK FULLPATH LEN
	do
		echo miss "$I|$FILE|$LINK|$LEN"
		
		FILE=${FILE%/}	#remove trailing backslash in order to avoid sync files in a directory directly
		
		#if a directory, symlink, device or special
		[[ $I =~ ^[c.][dLDS] && $FILE != '.' ]] && postpone_update "$FILE" && continue
		
		#if file only need to be update
		#This is dangerous and could ends in transfer (get out ou sync) new data if file changes meanwhile [[ $I =~ ^[.]f ]] && postpone_update "$FILE" && continue
		
		#this is the main (and most costly) case. A file, or part of it, need to be transfer
		[[ $I =~ ^[.\<]f ]] && (
			[[ -e $HASHDB ]] && IFS='|' read HASH TIME < <(
				sqlite3 "$HASHDB" "SELECT hash,time FROM H WHERE filename='$FILE'"
			)
			CTIME=$(stat -c "%Y" "$FULLPATH") || echo unable to get stat of file $FULLPATH
			#check if we need to compute a HASH
			[[ -z $HASH || -z $TIME || -z $CTIME || (($CTIME > $TIME )) ]] && {
				HASH=$(sha256sum -b "$FULLPATH" | cut -d' ' -f1)
				[[ -e $HASHDB ]] && sqlite3 "$HASHDB" "INSERT OR REPLACE INTO H ('hash','size','time','filename') VALUES ('$HASH','$LEN','$CTIME','$FILE');"
			}
			PREFIX=$(echo $HASH|sed -E 's#^(.)(.)(.)(.)(.)(.)#\1/\2/\3/\4/\5/\6/#')
			[[ $PREFIX =~ ././././././ ]] || { echo "Prefix $PREFIX !~ ././././././" && exit;}
			update_file "$FULLPATH" "$BACKUPURL/$RVID/@by-id/$PREFIX/$TYPE/$FILE"
		) && continue
		
		#if a hard link (to file or to symlink)
		[[ $I =~ ^h[fL] && $LINK =~ =\> ]] && LINK=$(echo $LINK|sed -E 's/\s*=>\s*//') &&  postpone_hl "$LINK" "$FILE" && continue
		
		#there are situations where the rsync don't know yet the target of a hardlink, so we need to flag this situation and later we take are of it
		[[ $I =~ ^h[fL] && ! $LINK =~ =\> ]] && HLINK=missing && continue

		echo Is something else
		
	done < <(dorsync --dry-run --archive --hard-links --relative --itemize-changes $PERM $PASS $EXC $FMT_QUERY2 "$SRC" "$DST")
	update_hardlinks "$BASE" "$DST"
	update_dirs	"$BASE" "$DST"
	remove_postpone_files
}
clean(){
	local SRC="$1/./$2"
	local DST=$3
	[[ -e $SRC ]] || ! echo $SRC does not exist || return 1
	dorsync -riHDR $CLEAN $PERM $PASS $FMT $EXC  "$SRC" "$DST" #clean deleted files
}
snapshot(){
	dorsync --dry-run --dirs --ignore-non-existing --ignore-existing $PASS "$ROOT/./" "$BACKUPURL/$RVID/@snap"
}
wait4jobs(){
	while list=($(jobs -rp)) && ((${#list[*]} > 0))
	do
		echo Wait for jobs "${list[@]}" to finish
		wait -n
	done
}

MANIFEST=$RUNDIR/manifest.$$
ENDFLAG=$RUNDIR/endflag.$$

bg_upload_manifest(){	
	local BASE="$1"
	local STARTDIR="$2"
	local DST="$3"
	local TYPE=${DST##*/}
	[[ -e $MANIFEST ]] || touch "$MANIFEST"
	[[ -e $ENDFLAG ]] && rm -f "$ENDFLAG"

	(	#start a subshell to run in background
		let START=1
		let LEN=500
		SEGMENT=$RUNDIR/segment.$$
		SEGFILES=$RUNDIR/segment-files.$$	
		while true
		do
			let END=LEN+START-1
			let CNT=$(sed -n "${START},${END}p;${END}q" "$MANIFEST"|tee "$SEGMENT" |wc -l)
			(( CNT == 0 )) && [[ -e $ENDFLAG ]] && break
			(( CNT == 0 )) && sleep 1 && continue
			(( CNT < LEN )) && sed -ni "1,${CNT}p" "$SEGMENT" 								#avoid send incomplete lines
			update_file "$SEGMENT" "$BACKUPURL/$RVID/@manifest/$TYPE/$STARTDIR/manifest.lst"
			update_file "$SEGMENT" "$BACKUPURL/$RVID/@apply-manifest/$TYPE/$STARTDIR/manifest.lst"		
			cut -d'|' -f4- "$SEGMENT" > "$SEGFILES"
			while IFS='|' read -r I FILE
			do
				echo miss "$I|$FILE"
				[[ $I == "<f++++"* ]] && (															#only meat! I mean only update data, nothing else, in this phase
					ID=$(fgrep -m1 "|$FILE" "$SEGMENT" | cut -d'|' -f1)
					[[ $ID =~ ././././././ ]] && update_file "$BASE/$FILE" "$BACKUPURL/$RVID/@by-id/$ID/$TYPE/$FILE"
				)
			done < <(dorsync --dry-run --links --size-only --files-from="$SEGFILES" --itemize-changes $EXC $PASS $FMT_QUERY3 "$BASE" "$DST")
			echo sent $CNT lines of manifest starting at $START
			let START+=CNT
		done
		rm -fv "$SEGMENT" "$SEGFILES"
	)&
}

bg_upload_manifest "$ROOT" "$STARTDIR" "$BACKUPURL/$RVID/@current/data"

echo Start to backup $BACKUPDIR at $(date -R)

echo Phase 1 - compute ids for new files and backup already server existing files

time (bash "$SDIR/hash.sh" $FSW "$BACKUPDIR" | sed -E 's#^(.)(.)(.)(.)(.)(.)#\1/\2/\3/\4/\5/\6/#' > "$MANIFEST") && echo got data hashes 
touch "$ENDFLAG"
wait4jobs
rm -fv "$MANIFEST" "$ENDFLAG"

echo Phase 2 - backup everything includind attributes and acls

time backup "$ROOT" "$STARTDIR" "$BACKUPURL/$RVID/@current/data" && echo backup data done

[[ -n $HLINK ]] && time backup "$ROOT" "$STARTDIR" "$BACKUPURL/$RVID/@current/data"	&& echo checked missed hardlinks

time clean "$ROOT" "$STARTDIR" "$BACKUPURL/$RVID/@current/data" && echo cleaned deleted files

OSTYPE=$(uname -o |tr '[:upper:]' '[:lower:]')

[[ $OSTYPE == 'cygwin' && $FILESYSTEM == 'NTFS' ]] && (
	METADATADIR=$SDIR/cache/metadata/by-volume/${VOLUMESERIALNUMBER:-_}
	SRCDIR=".bkit/$STARTDIR"
	[[ -d $METADATADIR/$SRCDIR ]] || mkdir -p "$METADATADIR/$SRCDIR"
	bash "$SDIR/acls.sh" "$BACKUPDIR" "$METADATADIR/$SRCDIR" 2>&1 |  xargs -d '\n' -I{} echo Acls: {} && echo got ACLS
	cd "$METADATADIR"
	PACKDIR=".tar/$STARTDIR"
	[[ -d $PACKDIR ]] || mkdir -p "$PACKDIR"
	tar --update --file "$PACKDIR/dir.tar" "$SRCDIR"
	backup "$METADATADIR" "$PACKDIR/dir.tar" "$BACKUPURL/$RVID/@current/metadata"
) && echo Metadata tar sent to backup

time snapshot && echo snapshot done 
 
echo Backup of $BACKUPDIR done at $(date -R)
