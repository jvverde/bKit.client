#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR
exists() { type "$1" >/dev/null 2>&1;}
die() { echo -e "$@">&2; exit 1; }

while [[ $1 =~ ^- ]]
do
	KEY="$1" && shift
	case "$KEY" in	
		-l|-log|--log)
			exec 1>"$1" 
			shift
		;;
		-f|--force)
			FSW='-f'
		;;
		-u|--uuid) 
			BACKUPDIR=$(bash "$SDIR/getdev.sh" "$1")		
			shift
		;;
		-d|--dir) 
			STARTDIR="$1" && shift
		;;
		-s|--snap) 
			SNAP=true
		;;
		*)
			die Unknow	option $KEY
		;;		
	esac
done

[[ -z $BACKUPDIR ]] && {
	BACKUPDIR="$1" && shift
}
MAPDRIVE="$1"

[[ -n $BACKUPDIR ]] || die "Usage:\n\t$0 [options] path [mapdrive]"

exists cygpath && BACKUPDIR=$(cygpath "$BACKUPDIR") && SDIR=$(cygpath "$SDIR")

BACKUPDIR=$(readlink -ne "$BACKUPDIR")

[[ -b $BACKUPDIR ]] && { #id it is a block device, then check if it is mounted and mount it if not
	DEV=$BACKUPDIR
	MOUNT=$(lsblk -lno MOUNTPOINT $DEV)
	[[ -n $MOUNT ]] || MOUNT=$(df --output=source,target|tail -n +2|fgrep "$DEV"|sort|head -n 1|awk '{print $2}')
	[[ -z $MOUNT ]] && MOUNT=/tmp/bkit-$(date +%s) && mkdir -pv $MOUNT && {
		mount -o ro $DEV  $MOUNT || die Cannot mount $DEV on $MOUNT
		trap "umount $DEV && rm -rvf $MOUNT" EXIT
	}
	ROOT=$MOUNT
} || {
	MOUNT=$(stat -c%m "$BACKUPDIR")
	[[ -z $STARTDIR ]] && STARTDIR=${BACKUPDIR#$MOUNT}
	STARTDIR=${STARTDIR#/}	
	DEV=$(df --output=source "$MOUNT"|tail -1)
	ROOT=$MOUNT
	[[ -n $MAPDRIVE ]] && exists cygpath && ROOT=$(cygpath "$MAPDRIVE")
}
BACKUPDIR="$ROOT/$STARTDIR"
[[ -d $BACKUPDIR ]] || die Cannot find directory $BACKUPDIR


[[ $SNAP == true ]] && "$SDIR/snap-backup.sh" "$BACKUPDIR" && exit

[[ $SNAP == true ]] && echo "Fail to create a snaphost. I will continue..."

source "$SDIR/drive.sh" "$DEV"

[[ $DRIVETYPE =~ Ram.Disk ]] && die Drive $DEV is a RAM Disk 
#compute Remote Volume ID
RVID="${DRIVE:-_}.${VOLUMESERIALNUMBER:-_}.${VOLUMENAME:-_}.${DRIVETYPE:-_}.${FILESYSTEM:-_}"
CONF="$SDIR/conf/conf.init"
[[ -f $CONF ]] || die Cannot found configuration file at $CONF
source "$CONF"

exists rsync || die Cannot find rsync
exists sqlite3 || die Cannot find sqlite3

trap '' SIGPIPE

dorsync(){
	local RETRIES=1000
	while true
	do
		rsync --one-file-system --compress "$@" 2>&1 
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
			*)
				echo Fail to backup. Exit value of rsync is non null: $ret 
				break
			;;
		esac
		(( --RETRIES < 0 )) && echo "I'm tired of trying" && break 
	done
}

RUNDIR=$SDIR/run
[[ -d $RUNDIR ]] || mkdir -p $RUNDIR
FLIST=$RUNDIR/file-list.$$
HLIST=$RUNDIR/hl-list.$$
DLIST=$RUNDIR/dir-list.$$
MANIFEST=$RUNDIR/manifest.$$
ENDFLAG=$RUNDIR/endflag.$$

trap "rm -fv $RUNDIR/*.$$ $RUNDIR/*.$$.*" EXIT

set_postpone_files(){
	exec 99>"$HLIST"
	exec 98>"$DLIST"
	exec 97>"$FLIST"
}
remove_postpone_files(){
	rm -f "$HLIST" "$DLIST" "$FLIST"
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
EXC="$SDIR/conf/excludes.txt"
PERM="--perms --acls --owner --group --super --numeric-ids"
OPTIONS=" --inplace --delete-delay --force --delete-excluded --stats --fuzzy"
CLEAN="--delete --force --delete-excluded --ignore-non-existing --ignore-existing"
FMT_QUERY='--out-format=%i|%n|%L|/%f'
FMT_QUERY2='--out-format=%i|%n|%L|/%f|%l'
FMT_QUERY3='--out-format=%i|%n'

export RSYNC_PASSWORD="$(cat "$SDIR/conf/pass.txt")"
[[ -e $SDIR/conf/excludes.txt ]] || bash "$SDIR/make-excludes.sh"

update_hardlinks(){
	FILE="${HLIST}.sort"
	LC_ALL=C sort -o "$FILE" "$HLIST"
	dorsync --archive --hard-links --relative --files-from="$FILE" --recursive --itemize-changes --exclude-from="$EXC" $PERM $FMT "$@"
	rm -f "$FILE"
}
update_dirs(){
	FILE="${DLIST}.sort"
	LC_ALL=C sort -o "$FILE" "$DLIST"
	dorsync --archive --relative --files-from="$FILE" --itemize-changes --exclude-from="$EXC" $PERM $FMT "$@"
	rm -f "$FILE"
}
update_file(){
	dorsync -tiz --inplace $PERM $FMT "$@"
}
update_files(){
	SRC=$1 && shift
	FILE="${SRC}.sort"
	LC_ALL=C sort -o "$FILE" "$SRC"
	dorsync --archive --inplace --hard-links --relative --files-from="$FILE" --recursive --itemize-changes --exclude-from="$EXC" $PERM $FMT "$@"
	rm -f "$FILE"
}

backup(){
	local BASE=$1
	local SRC="$1/./$2"
	local DST=$3
	[[ -e $SRC ]] || ! echo $SRC does not exists || return 1
	[[ -d $SRC ]] && local HASHDB=$(bash "$SDIR/hash.sh" -b "$SRC")
	local TYPE=${DST##*/}
	unset HLINK
	set_postpone_files
	while IFS='|' read -r I FILE LINK FULLPATH LEN
	do
		echo miss "$I|$FILE|$LINK|$LEN"
		
		FILE=${FILE%/}	#remove trailing backslash in order to avoid sync files in a directory directly
		
		#if a directory, symlink, device or special
		[[ $I =~ ^[c.][dLDS] && "$FILE" != '.' ]] && postpone_update "$FILE" && continue
		
		#if file only need to be update
		#This is dangerous and could ends in transfer (get out ou sync) new data if file changes meanwhile [[ $I =~ ^[.]f ]] && postpone_update "$FILE" && continue
		
		#this is the main (and most costly) case. A file, or part of it, need to be transfer
		[[ $I =~ ^[.\<]f ]] && (
			[[ -e $HASHDB ]] && IFS='|' read HASH SIZE TIME < <(
				sqlite3 "$HASHDB" "SELECT hash,size,time FROM H WHERE filename=\"$FILE\""
			)
			CTIME=$(stat -c "%Y" "$FULLPATH") || echo unable to get stat of file $FULLPATH
			#check if we need to compute a HASH
			[[ -z $HASH || -z $TIME || -z $CTIME || (($CTIME > $TIME )) ]] && {
				HASH=$(sha256sum -b "$FULLPATH" | cut -d' ' -f1)
				[[ -e $HASHDB ]] && sqlite3 "$HASHDB" "INSERT OR REPLACE INTO H ('hash','size','time','filename') VALUES ('$HASH','$LEN','$CTIME','$FILE');"
			}
			PREFIX=$(echo $HASH|sed -E 's#^(.)(.)(.)(.)(.)(.)#\1/\2/\3/\4/\5/\6/#')
			[[ $PREFIX =~ ././././././ ]] || { echo "Prefix $PREFIX !~ ././././././" && exit;}
			echo "$PREFIX|$SIZE|$TIME|$FILE" >> "$MANIFEST"
			#update_file "$FULLPATH" "$BACKUPURL/$RVID/@by-id/$PREFIX/$TYPE/$FILE"
		) && continue
		
		#if a hard link (to file or to symlink)
		[[ $I =~ ^h[fL] && $LINK =~ =\> ]] && LINK=$(echo $LINK|sed -E 's/\s*=>\s*//') &&  postpone_hl "$LINK" "$FILE" && continue
		
		#there are situations where the rsync don't know yet the target of a hardlink, so we need to flag this situation and later we take are of it
		[[ $I =~ ^h[fL] && ! $LINK =~ =\> ]] && HLINK=missing && continue

		echo Is something else
		
	done < <(dorsync --dry-run --archive --hard-links --relative --itemize-changes $PERM --exclude-from="$EXC" $FMT_QUERY2 "$SRC" "$DST")
	update_dirs	"$BASE" "$DST"
	update_hardlinks "$BASE" "$DST"
	remove_postpone_files
}
clean(){
	local SRC="$1/./$2"
	local DST=$3
	[[ -e $SRC ]] || ! echo $SRC does not exist || return 1
	dorsync -riHDR $CLEAN $PERM $FMT --exclude-from="$EXC"  "$SRC" "$DST" #clean deleted files
}
snapshot(){
	dorsync --dry-run --dirs --ignore-non-existing --ignore-existing "$ROOT/./" "$BACKUPURL/$RVID/@snap"
}
wait4jobs(){
	while list=($(jobs -rp)) && ((${#list[*]} > 0))
	do
		echo Wait for ${#list[*]} job to finish
		wait -n
	done
}

bg_upload_manifest(){	
	local BASE="$1"
	local STARTDIR="$2"
	[[ -e $MANIFEST ]] || touch "$MANIFEST"
	[[ -e $ENDFLAG ]] && rm -f "$ENDFLAG"

	(	#start a subshell to run in background
		let START=1
		let LEN=500
		SEGMENT=$RUNDIR/segment.$$
		SEGFILES=$RUNDIR/segment-files.$$	
		while [[ -e $MANIFEST ]]
		do
			let END=LEN+START-1
			let CNT=$(sed -n "${START},${END}p;${END}q" "$MANIFEST"|tee "$SEGMENT" |wc -l)
			(( CNT == 0 )) && [[ -e $ENDFLAG ]] && break
			(( CNT == 0 )) && sleep 1 && continue
			(( CNT < LEN )) && sed -ni "1,${CNT}p" "$SEGMENT" 								#avoid send incomplete lines
			update_file "$SEGMENT" "$BACKUPURL/$RVID/@manifest/data/$STARTDIR/manifest.lst"
			update_file "$SEGMENT" "$BACKUPURL/$RVID/@apply-manifest/data/$STARTDIR/manifest.lst"		
			cut -d'|' -f4- "$SEGMENT" > "$SEGFILES"
			update_files "$SEGFILES" "$BASE" "$BACKUPURL/$RVID/@seed/data"
			update_file "$SEGMENT" "$BACKUPURL/$RVID/@apply-seed/data/$STARTDIR/manifest.lst"		
			echo sent $CNT lines of manifest starting at $START
			let START+=CNT
		done
		rm -f "$SEGMENT" "$SEGFILES"
	)&
}

LOCK=$RUNDIR/${VOLUMESERIALNUMBER:-_}

(
	flock -w $((3600*24)) 9 || {
		rm -fv "$LOCK"
		die Volume $VOLUMESERIALNUMBER was locked
	}
	 	
	bg_upload_manifest "$ROOT" "$STARTDIR"

	echo Start to backup $BACKUPDIR at $(date -R)

	echo Phase 1 - compute ids for new files and backup already server existing files

	time (bash "$SDIR/hash.sh" $FSW "$BACKUPDIR" | sed -E 's#^(.)(.)(.)(.)(.)(.)#\1/\2/\3/\4/\5/\6/#' > "$MANIFEST") && echo got data hashes 
	touch "$ENDFLAG"
	wait4jobs
	rm -f "$MANIFEST" "$ENDFLAG"

	echo Phase 2 - backup everything includind attributes and acls

	bg_upload_manifest "$ROOT" "$STARTDIR"

	time backup "$ROOT" "$STARTDIR" "$BACKUPURL/$RVID/@current/data" && echo backup data done

	[[ -n $HLINK ]] && time backup "$ROOT" "$STARTDIR" "$BACKUPURL/$RVID/@current/data"	&& echo checked missed hardlinks

	touch "$ENDFLAG"
	wait4jobs
	rm -f "$MANIFEST" "$ENDFLAG"


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
		update_file -R "$METADATADIR/./$PACKDIR/dir.tar" "$BACKUPURL/$RVID/@current/metadata/"
	) && echo Metadata tar sent to backup

	time snapshot && echo snapshot done
	echo Backup of $BACKUPDIR done at $(date -R)
) 9>"$LOCK"

