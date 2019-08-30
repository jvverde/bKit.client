#!/usr/bin/env bash
SDIR="$(dirname -- "$(readlink -ne -- "$0")")"				#Full DIR

set -uE

source "$SDIR/lib/functions/all.sh"

SNAP='@snap'

declare -a options=()
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
			MOUNTPOINT="$1" && shift
			exists cygpath && MOUNTPOINT=$(cygpath "$MOUNTPOINT")
		;;
		--snap)
			SNAP="@snap/$1" && shift
		;;
		--snap=*)
			SNAP="@snap/${KEY#*=}"
		;;
		--burn)
			SNAP="@burn"
		;;
		--backupurl)
			BACKUPURL="$1" && shift
		;;
		--backupurl=*)
			BACKUPURL="${KEY#*=}"
		;;
		--rvid)
			export BKIT_RVID="$1" && shift
		;;
		--rvid=*)
			BKIT_RVID="${KEY#*=}"
		;;
		--config)
			CONFIG="$1" && shift
		;;
		--config=*)
			CONFIG="${KEY#*=}"
		;;
		--stats)
			stats=1
		;;
		--sendlogs)
			FULLREPORT=1
			NOTIFY=1
			stats=1
		;;
		--no-ssh)
			export NOSSH=1
		;;
		--notify)
			NOTIFY=1
			stats=1
		;;
		--email=*)
			EMAIL="${KEY#*=}"
			NOTIFY=1
			stats=1
		;;
		-- )
			while [[ $1 =~ ^- ]]
			do
				options+=("$1")
				shift
			done
		;;
		*)
			die Unknown	option $KEY
		;;
	esac
done

source "$SDIR/ccrsync.sh"

ARGS=("$@")

declare -a BASEDIR=()

ORIGINALDIR=( "${ARGS[@]}" ) #dir names as seen by the user (linux vs windows path)

exists cygpath && ARGS=( $(cygpath -u "${ORIGINALDIR[@]}") ) && ORIGINALDIR=( $(cygpath -w "${ARGS[@]}") )

#BASEDIR=( "$(readlink -e "${BASEDIR[@]}")" ) || die "Error:  readlink -e '${BASEDIR[@]}'"
while read file
do
  BASEDIR+=( "$file" )
done < <(readlink -e "${ARGS[@]}")


ROOTS=( $(stat -c%m "${BASEDIR[@]}") ) || die "Error: stat -c%m '${BASEDIR[@]}'"
ROOT=${ROOTS[0]}

[[ -e "$ROOT" ]] || die "I didn't find a disk for directory/file: '${BASEDIR[0]}'"

#[[ -n $MOUNTPOINT ]] || MOUNTPOINT=$ROOT
true ${MOUNTPOINT:="$ROOT"}

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
	BACKUPDIR+=( "$MOUNTPOINT/$DIR" )
done

#We need ROOT, BACKUPDIR and STARTDIR
#[[ ${BKIT_RVID:-} =~ .+\..+\..+\..+\..+ ]] || source "$SDIR/lib/rvid.sh" || die "Can't source rvid"
[[ ${BKIT_RVID+isset} == isset ]] || source "$SDIR/lib/rvid.sh" || die "Can't source rvid"


exists rsync || die Cannot find rsync

trap '' SIGPIPE

dorsync2(){
	local RETRIES=300
	while true
	do
    		#echo rsync "${RSYNCOPTIONS[@]}" --one-file-system --compress "$@"
    		rsync ${RSYNCOPTIONS+"${RSYNCOPTIONS[@]}"} ${options+"${options[@]}"} --one-file-system --compress "$@"
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

mktempdir RUNDIR || die "Can't create a temporary working directory"
FLIST="$RUNDIR/file-list.$$"
HLIST="$RUNDIR/hl-list.$$"
DLIST="$RUNDIR/dir-list.$$"
NOW="$(date +"%Y-%m-%dT%Hh%Mm%S(%:::z).%a.%W")"
logfile="$VARDIR/log/backup/$NOW.log"
errfile="$VARDIR/log/backup/$NOW.err"
statsfile="$VARDIR/log/backup/$NOW.stat"

mkdir -pv "${logfile%/*}" "${errfile%/*}" "${statsfile%/*}" #Just ensure that the log directory exists

exec 3>&2
exec 2> >(tee "$errfile" >&3)

#finish() {
#  cat "$errfile" >&3
#}
#
#atexit finish
#
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
PERM=(--perms --acls --owner --group --super --numeric-ids --devices --specials)
exists cygpath || PERM+=(-XX)
CLEAN=(--delete-delay --force --delete-excluded --ignore-non-existing --ignore-existing)

update_hardlinks(){
	FILE="${HLIST}.sort"
	LC_ALL=C sort -o "$FILE" "$HLIST"
	dorsync --delete --archive --hard-links --relative --files-from="$FILE" --recursive --itemize-changes "${PERM[@]}" $FMT "$@"
	rm -f "$FILE"
}
update_dirs(){
	FILE="${DLIST}.sort"
	LC_ALL=C sort -o "$FILE" "$DLIST"
	dorsync --delete --archive --relative --files-from="$FILE" --itemize-changes "${PERM[@]}" $FMT "$@"
	rm -f "$FILE"
}
update_file(){
	dorsync -tiz --inplace "${PERM[@]}" $FMT "$@"
}
update_files(){
	SRC=$1 && shift
	FILE="${SRC}.sort"
	LC_ALL=C sort -o "$FILE" "$SRC"
	dorsync --delete --archive --inplace --hard-links --relative --files-from="$FILE" --itemize-changes "${PERM[@]}" $FMT "$@"
	#echo dorsync --delete --archive --inplace --hard-links --relative --files-from="$FILE" --itemize-changes "${PERM[@]}" $FMT "$@"
	#cat "$FILE"
	rm -f "$FILE"
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
	dorsync --dry-run --ignore-non-existing --ignore-existing "$MOUNTPOINT/./" "$BACKUPURL/$BKIT_RVID/$SNAP"
}
prepare(){
	dorsync --dry-run --ignore-non-existing --ignore-existing "$MOUNTPOINT/./" "$BACKUPURL/$BKIT_RVID/@current/data"
}

exec {OUT}>&1
upload_manifest(){
  exec 1>&$OUT
  local BASE="$1"
  local PREFIX="$2"
  
  #echo upload manifest for $*  
  declare manifest="$RUNDIR/manifest.$$"
  declare files="$RUNDIR/files.$$"
  :> "$manifest"
  :> "$files"
  send_manifest(){
      update_file "$manifest" "$BACKUPURL/$BKIT_RVID/@manifest/$PREFIX/manifest.lst"
      update_file "$manifest" "$BACKUPURL/$BKIT_RVID/@apply-manifest/$PREFIX/manifest.lst"
      cut -d'|' -f4- "$manifest" > "$files"
      update_files "$files" "$BASE" "$BACKUPURL/$BKIT_RVID/@seed/$PREFIX"
      update_file "$manifest" "$BACKUPURL/$BKIT_RVID/@apply-seed/$PREFIX/manifest.lst"
      :> "$manifest"    
  }

  declare -i cnt=0
  
  while IFS= read -r line
  do
    echo "$line" >> "$manifest"
    (( ++cnt > 50 )) && {
      send_manifest
      (( cnt = 0 ))
    }
  done
  [[ -s $manifest ]] && send_manifest
}

backupACLS(){
  local FMT='--out-format=ACL:"%o|%i|%f|%c|%b|%l|%t"'
  local FMT_QUERY='--out-format=%i|/%f'
  local ACLFILE='.bkit-dir-acl'
  local BASE=$1 && shift
  declare -a SRCS=()
  declare -a MDIRS=()

  declare -r metadatadir="${VARDIR:-$SDIR}/cache-bkit/metadata/by-volume/${BKIT_VOLUMESERIALNUMBER:-_}/"
  
  [[ -d $metadatadir ]] || mkdir -pv "$metadatadir"

  for DIR in "$@"
  do
    SRCS+=( "$BASE/./$DIR" )
    [[ -d "${metadatadir}${DIR}" ]] || mkdir -pv "${metadatadir}${DIR}"
    MDIRS+=( "${metadatadir}${DIR}" )
  done

  local Loptions=(
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

  local ACLSoptions=(
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
      J=${I#????}             #remove first 4 characteres ex: >f.s #That means don't consider size (of course) only time, permisions, owners are important
      [[ $J =~ [^.] ]] && {
        echo "ACL miss:$I|$FILE" >&11
        echo "$FILE"
      }
    done < <(dorsync --dry-run "${Loptions[@]}" "${ACLSoptions[@]}" "${SRCS[@]}" "$metadatadir") |
      bash "$SDIR/storeACLs.sh" --diracl="$ACLFILE" "$metadatadir"
  } | sed -e 's/^/\t/'

    
  echo "b) Update attributes and Clean metafiles on local cache"
  {
    dorsync --ignore-non-existing --ignore-existing --delete --delete-excluded --force "${Loptions[@]}" "${SRCS[@]}" "$metadatadir"
  } | sed -e 's/^/\t/'

  echo "c) Backup metafiles from local cache to backup server"
  {
    coproc upload_manifest "$metadatadir" 'metadata'
    {
      #bash "$SDIR/hash.sh" --remotedir="$BKIT_RVID/@current/metadata" --root="$metadatadir" -- "${RSYNCOPTIONS[@]}" "${MDIRS[@]}"
      export BKIT_TARGET='metadata'
      export BKIT_MNTPOINT="$metadatadir"
      bash "$SDIR/hashit.sh"  ${options+"${options[@]}"} "${MDIRS[@]}"
    } >&"${COPROC[1]}"
    exec {COPROC[1]}>&-
    wait $COPROC_PID
  } | sed -e 's/^/\t/'
	
  echo "d) Update metafiles attributes"
  {
    update "$metadatadir" "$@" "$BACKUPURL/$BKIT_RVID/@current/metadata"
  } | sed -e 's/^/\t/'

  echo "e) Clean metafiles on server"
  {
    clean "$metadatadir" "$@" "$BACKUPURL/$BKIT_RVID/@current/metadata"
  } | sed -e 's/^/\t/'
}


update(){
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
  unset hlinks
  set_postpone_files

  coproc upload_manifest "$BASE" 'data'

  while IFS='|' read -r I FILE LINK FULLPATH LEN
  do
    #echo miss "$I|$FILE|$LINK|$LEN"

    FILE=${FILE%/}  #remove trailing backslash in order to avoid sync files in a directory directly

    #if it is a directory, symlink, device or special
    #[[ $I =~ ^[c.][dLDS] && "$FILE" != '.' ]] && postpone_update "$FILE" && continue
    [[ $I =~ ^[c.][dLDS] ]] && postpone_update "$FILE" && continue

    #this is the main (and most costly) case. A file, or part of it, need to be transfer
    [[ $I =~ ^[.\<]f ]] && {
      HASH=$(sha256sum -b "$FULLPATH" | cut -d' ' -f1)
      PREFIX=$(echo $HASH|sed -E 's#^(.)(.)(.)(.)(.)(.)#\1/\2/\3/\4/\5/\6/#')
      [[ $PREFIX =~ ././././././ ]] && 
        echo "$PREFIX|$(stat -c '%s|%Y' "$FULLPATH")|$FILE" >&"${COPROC[1]}" || 
          echo "Prefix '$PREFIX' !~ ././././././"
    } && continue

    #if it is a hard link (to file or to symlink)
    [[ $I =~ ^h[fL] && $LINK =~ =\> ]] && LINK="$(echo $LINK|sed -E 's/\s*=>\s*//')" &&  postpone_hl "$LINK" "$FILE" && continue

    #(if) There are situations where the rsync don't know yet the target of a hardlink, so we need to flag this situation and later we take care of it
    [[ $I =~ ^h[fL] && ! $LINK =~ =\> ]] && hlinks=missing && continue

    [[ $I =~ ^\*deleting ]] && continue

    echo "Hum.. Is something else:$I|$FILE|$LINK|$LEN"

  done < <(dorsync --dry-run --no-verbose --archive --hard-links --relative --itemize-changes "${PERM[@]}" $FMT_QUERY "${SRCS[@]}" "$DST")

  exec {COPROC[1]}>&-
  wait $COPROC_PID

  update_dirs "$BASE" "$DST"
  update_hardlinks "$BASE" "$DST"
  remove_postpone_files
}

backup(){
  coproc upload_manifest "$MOUNTPOINT" 'data'
  bash "$SDIR/hashit.sh" ${options+"${options[@]}"}  "${BACKUPDIR[@]}" >&"${COPROC[1]}"
  exec {COPROC[1]}>&-
  wait $COPROC_PID
} 
######################### Start Backup Algorithm #########################

declare -i cnt=0
ITIME=$(date -R)

{
  echo "Backup to $BACKUPURL"
  prepare

  echo "Start to backup directories/files on '${ORIGINALDIR[@]}' on $ITIME"
  echo -e "\nPhase $((++cnt)) - Backup new/modified files\n"

  backup
  
  echo -e "\nPhase $((++cnt)) - Update Symbolic links, Hard links, Directories, File attributes and... meanwhile changed files\n"

  update "$MOUNTPOINT" "${STARTDIR[@]}" "$BACKUPURL/$BKIT_RVID/@current/data"

  [[ ${hlinks+isset} == isset ]] && {
    echo -e "\n\tPhase ${cnt}.1 update delayed hardlinks"
    update "$MOUNTPOINT" "${STARTDIR[@]}" "$BACKUPURL/$BKIT_RVID/@current/data"
  }

  echo -e "\nPhase $((++cnt)) - Clean deleted files from backup\n"

  clean "$MOUNTPOINT" "${STARTDIR[@]}" "$BACKUPURL/$BKIT_RVID/@current/data"

  [[ $OS == 'cygwin' && $BKIT_FILESYSTEM == 'NTFS' ]] && (id -G|grep -qE '\b544\b') && (
    echo -e "\nPhase $((++cnt)) - Backup ACLS\n"
	#Need a better revision
    #backupACLS "$MOUNTPOINT" "${STARTDIR[@]}" |sed -e 's/^/\t/'
  )

  echo -e "\nPhase $((++cnt)) - Create a readonly snapshot on server\n"

  snapshot

  echo "Backup done on $(date -R) for:"
  for I in ${!ORIGINALDIR[@]}
  do
    echo "Files/directories '${ORIGINALDIR[$I]}' backed up on:"
    echo -e "\t$BACKUPURL/$BKIT_RVID/@current/data/${STARTDIR[$I]}"
  done
} | tee "$logfile"


######################### Now some stats if requested #########################

[[ ${stats+isset} == isset && -e $logfile && -e "$SDIR/lib/tools/stats/send-stats.pl" ]] && exists perl && {
  echo "------------Stats------------"
  deltatime "$(date -R)" "$ITIME"
  echo "Total time spent: $DELTATIME"
  exists cygpath && ROOT=$(cygpath -w "$ROOT")
  cat -v "$logfile" | grep -Pio '^".+"$' | awk -vA="$ROOT" 'BEGIN {FS = OFS = "|"} {print $1,$2,A $3,$4,$5,$6,$7}' | perl "$SDIR/lib/tools/stats/send-stats.pl"
  echo "------------End of Stats------------"
} | tee "$statsfile"

######################### Sent email if required #########################
[[ ${NOTIFY+isset} == isset  && ${DEST+isset} == isset && -s $statsfile ]] && (
  ME=$(uname -n)
  FULLDIRS=( $(readlink -e "${ORIGINALDIR[@]}") )     #get full paths
  exists cygpath &&  FULLDIRS=( $(cygpath -w "${FULLDIRS[@]}") )
  printf -v DIRS "%s, " "${FULLDIRS[@]}"
  DIRS=${DIRS%, } #rm last comma
  WHAT=$DIRS
  let NUMBEROFDIRS=${#FULLDIRS[@]}
  let LIMIT=3
  let EXTRADIRS=NUMBEROFDIRS-LIMIT
  ((NUMBEROFDIRS > LIMIT)) && WHAT="${FULLDIRS[0]} and $EXTRADIRS more directories/files"

  [[ -s $errfile ]] \
    && SUBJECT="Some errors occurred while backing up $WHAT on $ME at $(date +%Hh%Mm)" \
    || SUBJECT="Backup of $WHAT on $ME successfully finished at $(date +%Hh%Mm)"
  {
    echo "Backup of $DIRS"
    cat "$statsfile"

    [[ -s $errfile ]] && {
      echo -e "\n------------Errors found------------"
      cat "$errfile"
      echo "------------End of Errors------------"
    }

    [[ ${FULLREPORT+isset} == isset ]] && {
      echo -e "\n------------Full Logs------------"
      cat "$logfile"
      echo "------------End of Logs------------"
    }
  } | sendnotify "$SUBJECT" "$ME" "$DEST" 
)

[[ -s $errfile ]] && die "Backup done with some errors. Check $errfile" || rm "$errfile"

deltatime "$(date -R)" "$ITIME"
echo "Backup done in $DELTATIME"
exit 0

