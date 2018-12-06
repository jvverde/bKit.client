#!/usr/bin/env bash

SDIR="$(dirname -- "$(readlink -ne -- "$0")")"				#Full DIR

source "$SDIR/functions/util.sh"

trap 'die "BACKUP: caught SIGINT"' INT

OS=$(uname -o |tr '[:upper:]' '[:lower:]')

source "$SDIR/ccrsync.sh"

SNAP='@snap'

while [[ $1 =~ ^- ]]
do
	KEY="$1" && shift
	case "$KEY" in
    -l|-log|--log)
        exec 1>"$1"
        shift
    ;;
    -l=*|-log=*|--log=*)
      exec 1>"${KEY#*=}"
    ;;
    --logdir)
        redirectlogs $1 backup && shift
    ;;
    --logdir=*)
        redirectlogs "${KEY#*=}" backup
    ;;
		-f|--force)
			FSW='-f' #check if we need it
		;;
		-m|--map)
			MAPDRIVE="$1" && shift
			exists cygpath && MAPDRIVE=$(cygpath "$MAPDRIVE")
		;;
    --snap)
      SNAP="@snap/$1" && shift
    ;;
    --snap=*)
      SNAP="@snap/${KEY#*=}"
    ;;
    --backupurl)
      BACKUPURL="$1" && shift
    ;;
    --backupurl=*)
      BACKUPURL="${KEY#*=}"
    ;;
    --rvid)
      RVID="$1" && shift
    ;;
    --rvid=*)
      RVID="${KEY#*=}"
    ;;
    --config)
      CONFIG="$1" && shift
    ;;
    --config=*)
      CONFIG="${KEY#*=}"
    ;;
    --stats)
      STATS=1
    ;;
    --sendlogs)
      FULLREPORT=1
      NOTIFY=1
      STATS=1
    ;;
    --notify)
      NOTIFY=1
      STATS=1
    ;;
    --email=*)
      EMAIL="${KEY#*=}"
      NOTIFY=1
      STATS=1
    ;;
		-- )
			while [[ $1 =~ ^- ]]
			do
				RSYNCOPTIONS+=("$1")
				shift
			done
		;;
		*)
			die Unknown	option $KEY
		;;
	esac
done

BASEDIR=("$@")

ORIGINALDIR=( "${BASEDIR[@]}" )

OLDIFS=$IFS
IFS="
"
exists cygpath && BASEDIR=( $(cygpath -u "${ORIGINALDIR[@]}") ) && ORIGINALDIR=( $(cygpath -w "${BASEDIR[@]}") )

BASEDIR=( $(readlink -e "${BASEDIR[@]}") ) || die "Error:  readlink -e '${BASEDIR[@]}'"

ROOTS=( $(stat -c%m "${BASEDIR[@]}") ) || die "Error: stat -c%m '${BASEDIR[@]}'"
ROOT=${ROOTS[0]}

[[ -e "$ROOT" ]] || die "I didn't find a disk for directory/file: '${BASEDIR[0]}'"

[[ -n $MAPDRIVE ]] || MAPDRIVE=$ROOT

STARTDIR=()
BACKUPDIR=()
for I in ${!ROOTS[@]}
do
	[[ "${ROOTS[$I]}" == "$ROOT" ]] || {
		warn "Roots are not in the same logical volume. These will be ignored:\n\t${ORIGINALDIR[$I]}" && continue
	}
	DIR=${BASEDIR[$I]#$ROOT}
	DIR=${DIR#/}
	STARTDIR+=( "$DIR" )
	BACKUPDIR+=( "$MAPDRIVE/$DIR" )
done

#We need ROOT, BACKUPDIR and STARTDIR
[[ $RVID =~ .+\..+\..+\..+\..+ ]] || {
  IFS='|' read -r VOLUMENAME VOLUMESERIALNUMBER FILESYSTEM DRIVETYPE <<<$("$SDIR/drive.sh" "$ROOT")

  IFS=$OLDIFS

  [[ $DRIVETYPE =~ Ram.Disk ]] && die "These directories/files ${BACKUPDIR[@]} are in a RAM Disk"

  exists cygpath && DRIVE=$(cygpath -w "$ROOT")
  DRIVE=${DRIVE%%:*}

  #compute Remote Volume ID
  RVID="${DRIVE:-_}.${VOLUMESERIALNUMBER:-_}.${VOLUMENAME:-_}.${DRIVETYPE:-_}.${FILESYSTEM:-_}"
}

#[[ $BACKUPURL =~ rsync://.+@.+:[0-9]+/.+ ]] || {
#  CONFIG="$SDIR/conf/conf.init"
#  [[ -f $CONFIG ]] || die Cannot found configuration file at $CONFIG
#  source "$CONFIG"
#}

exists rsync || die Cannot find rsync

trap '' SIGPIPE

dorsync2(){
	local RETRIES=300
	while true
	do
    		#echo rsync "${RSYNCOPTIONS[@]}" --one-file-system --compress "$@"
    		rsync "${RSYNCOPTIONS[@]}" --one-file-system --compress "$@"
		local ret=$?
		case $ret in
			0) break 									#this is a success
			;;
			5|10|12|30|35)
				DELAY=$((1 + RANDOM % 60))
				warn "Received error $ret. Try again in $DELAY seconds"
				sleep $DELAY
				warn "Try again now"
			;;
			*)
				warn "Fail to backup. Exit value of rsync is non null: $ret"
				break
			;;
		esac
		(( --RETRIES < 0 )) && warn "I'm tired of trying" && break
	done
}

dorsync(){
	dorsync2 "$@" | grep -v 'unpack_smb_acl'
}

#RUNDIR=$SDIR/run
RUNDIR="$(mktemp -d --suffix=.bKit)" || die "Can't create a temporary working directory"
[[ -d $RUNDIR ]] || mkdir -p "$RUNDIR"
FLIST="$RUNDIR/file-list"
HLIST="$RUNDIR/hl-list"
DLIST="$RUNDIR/dir-list"
MANIFEST="$RUNDIR/manifest"
ENDFLAG="$RUNDIR/endflag"
LOCK="$RUNDIR/${VOLUMESERIALNUMBER:-_}"
LOGFILE="$RUNDIR/logs"
ERRFILE="$RUNDIR/errors"
STATSFILE="$RUNDIR/stats"

exec 3>&2
exec 2>"$ERRFILE"

finish() {
  cat "$ERRFILE" >&3
  rm -rf $RUNDIR
}

trap finish EXIT

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
PERM=(--perms --acls --owner --group --super --numeric-ids)
CLEAN=(--delete-delay --force --delete-excluded --ignore-non-existing --ignore-existing)


update_hardlinks(){
	FILE="${HLIST}.sort"
	LC_ALL=C sort -o "$FILE" "$HLIST"
	dorsync --archive --hard-links --relative --files-from="$FILE" --recursive --itemize-changes "${PERM[@]}" $FMT "$@"
	rm -f "$FILE"
}
update_dirs(){
	FILE="${DLIST}.sort"
	LC_ALL=C sort -o "$FILE" "$DLIST"
	dorsync --archive --relative --files-from="$FILE" --itemize-changes "${PERM[@]}" $FMT "$@"
	rm -f "$FILE"
}
update_file(){
	dorsync -tiz --inplace "${PERM[@]}" $FMT "$@"
}
update_files(){
	SRC=$1 && shift
	FILE="${SRC}.sort"
	LC_ALL=C sort -o "$FILE" "$SRC"
	dorsync --archive --inplace --hard-links --relative --files-from="$FILE" --itemize-changes "${PERM[@]}" $FMT "$@"
	rm -f "$FILE"
}

backup(){
  local FMT_QUERY='--out-format=%i|%n|%L|/%f|%l'
	local BASE=$(readlink -e "$1") && shift
	#local SRC="$1/./$2"
	local SRCS=()
	for DIR in "${@:1:$#-1}"
	do
    DIR=${DIR#/}    #remove any leading slash if any}
		SRCS+=( "$BASE/./$DIR" )
	done
	local DST="${@: -1}" #last argument
	unset HLINK
	set_postpone_files

	while IFS='|' read -r I FILE LINK FULLPATH LEN
	do
		echo miss "$I|$FILE|$LINK|$LEN"

		FILE=${FILE%/}	#remove trailing backslash in order to avoid sync files in a directory directly

		#if it is a directory, symlink, device or special
    #[[ $I =~ ^[c.][dLDS] && "$FILE" != '.' ]] && postpone_update "$FILE" && continue
    [[ $I =~ ^[c.][dLDS] ]] && postpone_update "$FILE" && continue

		#this is the main (and most costly) case. A file, or part of it, need to be transfer
		[[ $I =~ ^[.\<]f ]] && (
			HASH=$(sha256sum -b "$FULLPATH" | cut -d' ' -f1)
			PREFIX=$(echo $HASH|sed -E 's#^(.)(.)(.)(.)(.)(.)#\1/\2/\3/\4/\5/\6/#')
			[[ $PREFIX =~ ././././././ ]] || { echo "Prefix $PREFIX !~ ././././././" && exit;}
			#echo "$PREFIX|$(stat -c '%s|%Y' "$FULLPATH")|$FILE"
			echo "$PREFIX|$(stat -c '%s|%Y' "$FULLPATH")|$FILE" >> "$MANIFEST"
		) && continue

		#if a hard link (to file or to symlink)
		[[ $I =~ ^h[fL] && $LINK =~ =\> ]] && LINK=$(echo $LINK|sed -E 's/\s*=>\s*//') &&  postpone_hl "$LINK" "$FILE" && continue

		#there are situations where the rsync don't know yet the target of a hardlink, so we need to flag this situation and later we take care of it
		[[ $I =~ ^h[fL] && ! $LINK =~ =\> ]] && HLINK=missing && continue

		echo "Is something else:$I|$FILE|$LINK|$LEN"

	done < <(dorsync --dry-run --no-verbose --archive --hard-links --relative --itemize-changes "${PERM[@]}" $FMT_QUERY "${SRCS[@]}" "$DST")
	update_dirs	"$BASE" "$DST"
	update_hardlinks "$BASE" "$DST"
	remove_postpone_files
}

clean(){
	local BASE=$1 && shift
	#local SRC="$1/./$2"
	local SRCS=()
	for DIR in "${@:1:$#-1}"
	do
		SRCS+=( "$BASE/./$DIR" )
	done
	local DST="${@: -1}" #last argument

	dorsync -riHDR "${CLEAN[@]}" "${PERM[@]}" $FMT "${SRCS[@]}" "$DST" #clean deleted files
}
snapshot(){
	dorsync --dry-run --ignore-non-existing --ignore-existing "$MAPDRIVE/./" "$BACKUPURL/$RVID/$SNAP"
}
prepare(){
	dorsync --dry-run --ignore-non-existing --ignore-existing "$MAPDRIVE/./" "$BACKUPURL/$RVID/@current/data"
}
wait4jobs(){
	while list=($(jobs -rp)) && ((${#list[*]} > 0))
	do
		#10.11.echo Wait for ${#list[*]} job to finish
		wait -n
	done
}

bg_upload_manifest(){
	local BASE="$1"
	local PREFIX="$2"
	[[ -e $MANIFEST ]] || touch "$MANIFEST"
	[[ -e $ENDFLAG ]] && rm -f "$ENDFLAG"

	(	#start a subshell to run in background
		let START=1
		let LEN=500
		SEGMENT=$RUNDIR/manifest-segment.$$
		SEGFILES=$RUNDIR/segment-files.$$
		while [[ -e $MANIFEST ]]
		do
			let END=LEN+START-1
			let CNT=$(sed -n "${START},${END}p;${END}q" "$MANIFEST"|tee "$SEGMENT" |wc -l)
			(( CNT == 0 )) && [[ -e $ENDFLAG ]] && break
			(( CNT == 0 )) && sleep 1 && continue
			(( CNT < LEN )) && sed -ni "1,${CNT}p" "$SEGMENT" 								#avoid send incomplete lines
			update_file "$SEGMENT" "$BACKUPURL/$RVID/@manifest/$PREFIX/manifest.lst"
			update_file "$SEGMENT" "$BACKUPURL/$RVID/@apply-manifest/$PREFIX/manifest.lst"
			cut -d'|' -f4- "$SEGMENT" > "$SEGFILES"
			update_files "$SEGFILES" "$BASE" "$BACKUPURL/$RVID/@seed/$PREFIX"
			update_file "$SEGMENT" "$BACKUPURL/$RVID/@apply-seed/$PREFIX/manifest.lst"
			echo sent $CNT lines of manifest starting at $START
			let START+=CNT
		done
		rm -f "$SEGMENT" "$SEGFILES"
	)&
}

backupACLS(){
  local FMT='--out-format=ACL:"%o|%i|%f|%c|%b|%l|%t"'
  local FMT_QUERY='--out-format=%i|/%f'
  local ACLFILE='.bkit-dir-acl'
  local BASE=$1 && shift
  local SRCS=()
  local MDIRS=()

  local METADATADIR=$SDIR/cache/metadata/by-volume/${VOLUMESERIALNUMBER:-_}/
  [[ -d $METADATADIR ]] || mkdir -pv "$METADATADIR"

  for DIR in "$@"
  do
    SRCS+=( "$BASE/./$DIR" )
    [[ -d "$METADATADIR$DIR" ]] || mkdir -pv "$METADATADIR$DIR"
    MDIRS+=( "$METADATADIR$DIR" )
  done

  local LOPTIONS=(
    --no-verbose
    --recursive
    --relative
    --super
    --times
    --itemize-changes
    --exclude="$ACLFILE"
    --exclude=".rsync-filter"
    $FMT_QUERY
  )

  local ACLSOPTIONS=(
    --acls
    --owner
    --group
    --perms
  )

  echo "a) Generate missing metafiles in local cache"
  {

    exec 11>&1
    while IFS='|' read -r I FILE
    do
      [[ $I =~ skipping ]] && continue
      #J=${I#?????}           #remove first 5 characteres ex: >f.st
      J=${I#????}             #remove first 4 characteres ex: >f.s
      [[ $J =~ [^.] ]] && {
        echo "ACL miss:$I|$FILE" >&11
        echo "$FILE"
      }
    done < <(dorsync --dry-run "${LOPTIONS[@]}" "${ACLSOPTIONS[@]}" "${SRCS[@]}" "$METADATADIR") |
      bash "$SDIR/storeACLs.sh" --diracl="$ACLFILE" "$METADATADIR"
  } | sed -e 's/^/\t/'

  echo "b) Update attributes and Clean metafiles on local cache"
  {
    dorsync --ignore-non-existing --ignore-existing --delete --delete-excluded --force "${LOPTIONS[@]}" "${SRCS[@]}" "$METADATADIR"
  } | sed -e 's/^/\t/'

  echo "c) Backup metafiles from local cache to backup server"
  {
    bg_upload_manifest "$METADATADIR" 'metadata'
    {
	#bash "$SDIR/hash.sh" --remotedir="$RVID/@current/metadata" --root="$METADATADIR" -- "${RSYNCOPTIONS[@]}" "${MDIRS[@]}"
	export CMPTARGET='metadata'
	bash "$SDIR/hashit.sh"  "${MDIRS[@]}"
    } > "$MANIFEST"

    touch "$ENDFLAG"
    wait4jobs
    rm -f "$MANIFEST" "$ENDFLAG"
  } | sed -e 's/^/\t/'

  echo "d) Update metafiles attributes"
  {
    bg_upload_manifest "$METADATADIR" 'metadata'

    backup "$METADATADIR" "$@" "$BACKUPURL/$RVID/@current/metadata"

    touch "$ENDFLAG"
    wait4jobs
    rm -f "$MANIFEST" "$ENDFLAG"
  } | sed -e 's/^/\t/'

  echo "e) Clean metafiles on server"
  {
    clean "$METADATADIR" "$@" "$BACKUPURL/$RVID/@current/metadata"
  } | sed -e 's/^/\t/'
}


#(
#  flock -w $((3600*24)) 9 || {
#    rm -fv "$LOCK"
#    die Volume $VOLUMESERIALNUMBER was locked for 1 day
#  }

  ITIME=$(date -R)

  {
    prepare

    bg_upload_manifest "$MAPDRIVE" 'data'
    echo Start to backup directories/files on ${ORIGINALDIR[@]} on $ITIME
    echo -e "\nPhase 1 - Backup new/modified files\n"

    #bash "$SDIR/hash.sh" --remotedir="$RVID/@current/data" -- "${RSYNCOPTIONS[@]}" "${BACKUPDIR[@]}" | sed -E 's#^(.)(.)(.)(.)(.)(.)#\1/\2/\3/\4/\5/\6/#' > "$MANIFEST"
    bash "$SDIR/hashit.sh"  "${BACKUPDIR[@]}" > "$MANIFEST"

    touch "$ENDFLAG"
    wait4jobs
    rm -f "$MANIFEST" "$ENDFLAG"
    echo -e "\nPhase 2 - Update Symbolic links, Hard links, Directories and file attributes\n"

    bg_upload_manifest "$MAPDRIVE" 'data'

    backup "$MAPDRIVE" "${STARTDIR[@]}" "$BACKUPURL/$RVID/@current/data"

    touch "$ENDFLAG"
    wait4jobs
    rm -f "$MANIFEST" "$ENDFLAG"

    [[ -n $HLINK ]] && {
      echo -e "\n\tPhase 2.1 update delayed hardlinks"
      backup "$MAPDRIVE" "${STARTDIR[@]}" "$BACKUPURL/$RVID/@current/data"
    }

    echo -e "\nPhase 3 - Clean deleted files from backup\n"

    clean "$MAPDRIVE" "${STARTDIR[@]}" "$BACKUPURL/$RVID/@current/data"

    [[ $OS == 'cygwin' && $FILESYSTEM == 'NTFS' ]] && (id -G|grep -qE '\b544\b') && (
      echo -e "\nPhase 4 - Backup ACLS\n"
      backupACLS "$MAPDRIVE" "${STARTDIR[@]}" |sed -e 's/^/\t/'
    )

    echo -e "\nPhase 5 - Create a readonly snapshot on server\n"

    snapshot

    echo "Backup done on $(date -R) for:"
    for I in ${!ORIGINALDIR[@]}
    do
      echo "Files/directories '${ORIGINALDIR[$I]}' backed up on:"
      echo -e "\t$BACKUPURL/$RVID/@current/data/${STARTDIR[$I]}"
    done
  } | tee "$LOGFILE"

  #Now some stats

  [[ -n $STATS && -e $LOGFILE && -e "$SDIR/tools/send-stats.pl" ]] && exists perl && {
    echo "------------Stats------------"
    deltatime "$(date -R)" "$ITIME"
    echo "Total time spent: $DELTATIME"
    exists cygpath && ROOT=$(cygpath -w "$ROOT")
    cat -v "$LOGFILE" | grep -Pio '^".+"$' | awk -vA="$ROOT" 'BEGIN {FS = OFS = "|"} {print $1,$2,A $3,$4,$5,$6,$7}' | perl "$SDIR/tools/send-stats.pl"
    echo "------------End of Stats------------"
  } | tee "$STATSFILE"

  #Sent email if required
  [[ -n $NOTIFY && -s $STATSFILE ]] && (
    ME=$(uname -n)
    FULLDIRS=( $(readlink -e "${ORIGINALDIR[@]}") )     #get full paths
    exists cygpath &&  FULLDIRS=( $(cygpath -w "${FULLDIRS[@]}") )
    printf -v DIRS "%s, " "${FULLDIRS[@]}"
    DIRS=${DIRS%, }
    WHAT=$DIRS
    let NUMBEROFDIRS=${#FULLDIRS[@]}
    let LIMIT=3
    let EXTRADIRS=NUMBEROFDIRS-LIMIT
    ((NUMBEROFDIRS > LIMIT)) && WHAT="${FULLDIRS[0]} and $EXTRADIRS more directories/files"
    [[ -s $ERRFILE ]] && SUBJECT="Some errors occurred while backing up $WHAT on $ME at $(date +%Hh%Mm)" ||
    SUBJECT="Backup of $WHAT on $ME successfully finished at $(date +%Hh%Mm)"
    {
      echo "Backup of $DIRS"
      cat "$STATSFILE"

      [[ -s $ERRFILE ]] && {
        echo -e "\n------------Errors found------------"
        cat "$ERRFILE"
        echo "------------End of Errors------------"
      }

      [[ -n $FULLREPORT ]] && {
        echo -e "\n------------Full Logs------------"
        cat "$LOGFILE"
        echo "------------End of Logs------------"
      }
    } | sendnotify "$SUBJECT" "$DEST" "$ME"
  )
  [[ -s $ERRFILE ]] && {  
	  echo -e "\n------------Errors found------------"
	  cat "$ERRFILE"
	  echo "------------End of Errors------------"
	  die "Backup finished but some errors occurs"
  }
  deltatime "$(date -R)" "$ITIME"
  echo "Backup done in $DELTATIME"
  exit 0
#) 9>"$LOCK"

