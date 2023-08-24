#!/usr/bin/env bash
SDIR="$(dirname -- "$(readlink -ne -- "$0")")"				#Full DIR

set -uE

source "$SDIR/lib/functions/all.sh"

SNAP='@snap'

set_server () {
  source "$SDIR"/server.sh "$1"
}

declare -a options=()
while [[ ${1:+$1} =~ ^- ]]
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
    -s|--server)
      set_server "$1" && shift
    ;;
    -s=*|--server=*)
      set_server "${KEY#*=}"
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
    --dry-run)
      declare dryrun="dryrun"
      options+=("--dry-run")
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

declare -a ORIGINALDIR=( "${@:-.}" ) #dir names as seen by the user (linux vs windows path)
declare -a ARGS=("${@:-.}")

exists cygpath && {
  ARGS=()
  ORIGINALDIR=()  
  for arg in "${@:-.}"
  do
    ARGS+=( "$(cygpath -u "$arg")" )
    ORIGINALDIR+=( "$(cygpath -w "$arg")" )
  done
}

declare -a BASEDIR=()

for arg in "${ARGS[@]}"
do
  basepath="$(readlink -en "$arg")" || {
    warn "'$arg' doesn't seem to exist. It won't be selected to backup"
    continue
  }
  BASEDIR+=( "$basepath" )
done

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

[[ ${BKIT_RVID+isset} == isset ]] || source "$SDIR/lib/rvid.sh" "$ROOT" || die "Can't source rvid"


exists rsync || die Cannot find rsync

trap '' SIGPIPE

dorsync2(){
	local RETRIES=900
  local TIMEOUT=300
  local CTIMEOUT=120
  local NOCOMP='nef/3g2/3gp/7z/aac/ace/apk/avi/bz2/deb/dmg/ear/f4v/flac/flv/gpg/gz/iso/jar/jpeg/jpg/lrz/lz/lz4/lzma/lzo/m1a/m1v/m2a/m2ts/m2v/m4a/m4b/m4p/m4r/m4v/mka/mkv/mov/mp1/mp2/mp3/mp4/mpa/mpeg/mpg/mpv/mts/odb/odf/odg/odi/odm/odp/ods/odt/oga/ogg/ogm/ogv/ogx/opus/otg/oth/otp/ots/ott/oxt/png/qt/rar/rpm/rz/rzip/spx/squashfs/sxc/sxd/sxg/sxm/sxw/sz/tbz/tbz2/tgz/tlz/ts/txz/tzo/vob/war/webm/webp/xz/z/zip/zst'
	while true
	do
    rsync --contimeout=$CTIMEOUT --timeout=$TIMEOUT --skip-compress=$NOCOMP ${RSYNCOPTIONS+"${RSYNCOPTIONS[@]}"} ${options+"${options[@]}"} --one-file-system --compress "$@"
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
DLIST="$RUNDIR/dir-list.$$"
NOW="$(date +"%Y-%m-%dT%Hh%Mm%S(%:::z).%a.%W")"
logfile="$VARDIR/log/backup/$NOW.log"
errfile="$VARDIR/log/backup/$NOW.err"
statsfile="$VARDIR/log/backup/$NOW.stat"

mkdir -pv "${logfile%/*}" "${errfile%/*}" "${statsfile%/*}" #Just ensure that the log directory exists

#redirect to STDERR first free File Descriptor and asssign it to ERRFILE
exec {ERRFILE}>&2
#Redirect STDERR to $errfile and also to ERRFILE descriptor
exec 2> >(tee "$errfile" >&$ERRFILE)
#do the same for STDOUT
exec {OUTFILE}>&1
exec 1> >(tee "$logfile" >&$OUTFILE)
#Get first free descripot and assing in to OUT and redirect it to STDOUT
exec {OUT}>&1


set_postpone_files(){
  #Get first free descritor, assign it to FDB and redirect it to $DLIST 
	exec {FDB}>"$DLIST"
  #Get first free descritor, assign it to FDC and redirect it to $FLIST 
	exec {FDC}>"$FLIST"
}

FMT='--out-format="%o|%i|%f|%c|%b|%l|%t"'
PERM=(--perms --acls --owner --group --super --numeric-ids --devices --specials)
exists cygpath || PERM+=(-XX)
#CLEAN=(--delete-delay --force --delete-excluded --ignore-non-existing --ignore-existing)
CLEAN=(--delete-after --force --ignore-non-existing --ignore-existing)

update_bg(){
  exec {TMP}>&1
  exec 1>&$OUT
  declare -ar ARGS=("$@")
  declare -r HLIST="${RUNDIR:-/tmp}/hl-list.$$"
  
  :> "$HLIST"

  send_hl(){
    declare -r FILE="${HLIST}.sort"
    LC_ALL=C sort -u -o "$FILE" "$HLIST"
    :> "$HLIST"
    #dorsync --delete --archive --hard-links --relative --files-from="$FILE" --recursive --itemize-changes "${PERM[@]}" $FMT "${ARGS[@]}"
    dorsync --archive --hard-links --relative --files-from="$FILE" --itemize-changes "${PERM[@]}" $FMT "${ARGS[@]}"
  }
  
  declare -i cnt=0
  while IFS='|' read -r file
  do
    echo "${file}" >> "$HLIST"
    (( ++cnt >= 50 )) && {
      send_hl
      (( cnt = 0 ))
    }
  done
  [[ -s $HLIST ]] && send_hl
  rm -f "$HLIST"
  exec {TMP}>&-
}

# update_dirs(){
# 	FILE="${DLIST}.sort"
# 	LC_ALL=C sort -o "$FILE" "$DLIST"
# 	dorsync --delete --archive --relative --files-from="$FILE" --itemize-changes "${PERM[@]}" $FMT "$@"
# 	rm -f "$FILE"
# }
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

	dorsync -riHDR --timeout=0 "${CLEAN[@]}" "${PERM[@]}" $FMT "${SRCS[@]}" "$DST" #clean deleted files
}

snapshot(){
	dorsync --dry-run --ignore-non-existing --ignore-existing "$MOUNTPOINT/./" "$BACKUPURL/$BKIT_RVID/$SNAP"
}
prepare(){
	dorsync --dry-run --ignore-non-existing --ignore-existing "$MOUNTPOINT/./" "$BACKUPURL/$BKIT_RVID/@current/data"
}

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

  coproc upload_proc (
    upload_manifest "$BASE" 'data'
  )

  HLFIFI="$RUNDIR/hl-fifi.$$"
  HLFIFO="$RUNDIR/hl-fifo.$$"
  [[ -e "$HLFIFI" ]] || mkfifo "$HLFIFI"
  [[ -e "$HLFIFO" ]] || mkfifo "$HLFIFO"

  ( update_bg "$BASE" "$DST" <"$HLFIFI">"$HLFIFO" )&

  #Redirect FIFI/FIFO descriptor to fifo
  exec {FIFI}>"$HLFIFI"
  exec {FIFO}<"$HLFIFO"

  while IFS='|' read -r I FILE LINK FULLPATH LEN
  do
    #echo miss "$I|$FILE|$LINK|$LEN"

    FILE=${FILE%/}  #remove trailing backslash in order to avoid sync files in a directory directly

    #if it is a hard link (to file or to symlink)
    [[ $I =~ ^h[fLS] && $LINK =~ =\> ]] && echo -e "${LINK# => }\n${FILE}" >&"$FIFI" && continue

     #(if) There are situations where the rsync don't know (yet) the target of a hardlink, so we need to flag this situation and later we take care of it
    [[ $I =~ ^h[fLS] && ! $LINK =~ =\> ]] && hlinks=missing && continue

    #If it is a file and it is not being updated
    [[ $I =~ ^[.]f ]] && echo -e "${FILE}" >&"$FIFI" && continue


    #if it is a directory, symlink, device or special
    [[ $I =~ ^[c.][dLDS] ]] && echo "$FILE" >&"$FIFI" && continue

    #this is the main (and most costly) case. A file, or part of it, need to be transfer
    [[ $I =~ ^[\<]f ]] && {
      HASH=$(sha256sum -b "$FULLPATH" | cut -d' ' -f1)
      PREFIX=$(echo $HASH|sed -E 's#^(.)(.)(.)(.)(.)(.)#\1/\2/\3/\4/\5/\6/#')
      [[ $PREFIX =~ ././././././ ]] && 
        echo "$PREFIX|$(stat -c '%s|%Y' "$FULLPATH")|$FILE" >&"${upload_proc[1]}" || 
          echo "Prefix '$PREFIX' !~ ././././././"
    } && continue


    [[ $I =~ ^\*deleting ]] && continue

    echo "Hum.. Is something else:$I|$FILE|$LINK|$LEN"

  done < <(dorsync --dry-run --no-verbose --archive --hard-links --relative --itemize-changes "${PERM[@]}" $FMT_QUERY "${SRCS[@]}" "$DST")

  exec {upload_proc[1]}>&-
  wait $upload_proc_PID
  exec {FIFI}>&- #close FIFI descriptor
  #read -t 600 <&$FIFO
  read <&$FIFO #Wait untile FIFO is closed

}

backup(){
  coproc upload_manifest "$MOUNTPOINT" 'data'
  stdbuf -i0 -o0 -e0 perl "$SDIR/hashit.pl" ${options+"${options[@]}"}  "${BACKUPDIR[@]}" >&"${COPROC[1]}"
  exec {COPROC[1]}>&-
  wait $COPROC_PID
} 
######################### Start Backup Algorithm #########################

declare -i cnt=0
ITIME=$(date -R)

{
  echo "Backup to $BACKUPURL"
  prepare

  echo "Start to backup directories/files for '${ORIGINALDIR[@]}' on $ITIME"
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

  #[[ $OS == 'cygwin' && $BKIT_FILESYSTEM == 'NTFS' ]] && (id -G|grep -qE '\b544\b') && (
  #  echo -e "\nPhase $((++cnt)) - Backup ACLS\n"
	#Need a better revision
    #backupACLS "$MOUNTPOINT" "${STARTDIR[@]}" |sed -e 's/^/\t/'
  #)

  [[ ${dryrun+isset} == isset ]] || {
    echo -e "\nPhase $((++cnt)) - Create a readonly snapshot on server\n"

    snapshot
  }

  echo "Backup done on $(date -R) for:"
  for I in ${!ORIGINALDIR[@]}
  do
    echo "Files/directories '${ORIGINALDIR[$I]}' backed up on:"
    echo -e "\t$BACKUPURL/$BKIT_RVID/@current/data/${STARTDIR[$I]}"
  done
}

###############################################################################
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
[[ ${NOTIFY+isset} == isset && -s $statsfile ]] && (
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
  } | sendnotify "$SUBJECT" "$ME" "${EMAIL:-}" 
)

[[ -s $errfile ]] && echo "Backup done with some errors. Please check '$errfile'" || rm "$errfile"

deltatime "$(date -R)" "$ITIME"
echo "Backup done in $DELTATIME"
exit 0

