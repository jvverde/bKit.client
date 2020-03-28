#!/usr/bin/env bash
sdir="$(dirname -- "$(readlink -ne -- "$0")")"       #Full DIR

set -uE
set -o pipefail

source "$sdir/lib/functions/all.sh"

declare -r fmt='--out-format="%o|%i|%f|%M|%b|%l|%t"'
declare -ra perm=(--perms --acls --super --numeric-ids)
declare -r suffix=".before-restore-on"
declare localbackup="$suffix-$(date +"%Y-%m-%dT%H-%M-%S").bkit"
while [[ -e $localbackup ]]
do
  localbackup="${localbackup}_"
done

declare -a options=(
  --backup
  --backup-dir="$localbackup"
  --archive
  --exclude="${suffix}*"
  --hard-links
  --compress
  --human-readable
  --relative
  --partial
  --partial-dir=".bkit.rsync-partial"
  #--delay-updates 
  --super
)


dorsync() {
  local localdir="${@: -1}$localbackup"
  mkdir -p "$localdir" 2>/dev/null
  rsync ${perm+"${perm[@]}"} "$fmt" ${options+"${options[@]}"} ${RSYNCOPTIONS+"${RSYNCOPTIONS[@]}"} "$@"
  RET=$?
  #delete empty before-localdir dirs
  find "$localdir" -maxdepth 0 -empty -delete 2>/dev/null
  [[ -e "$localdir" ]] && {
    exists cygpath && localdir=$(cygpath -w "$localdir")
    echo Old files saved on "$localdir"
  }
  return $RET
}

destination() {
  declare -g dest="$1"
  [[ -e $dest ]] || mkdir -pv "$dest"
  exists cygpath && dest=$(cygpath -u "$dest")
  dest=$(readlink -ne "$dest")
  [[ -d $dest ]] || die "'$1' should be a directory"
  [[ ${dest: -1} == / ]] || dest="$dest/"
  echo "dest='$dest'"
}

usage() {
  local NAME=${1:-"$(basename -s .sh "$0")"}
  echo -e "Usage:\n\t $NAME [--dry-run] [--permissions] [--delete] [--dst=directory] [--snap=snap] [--local-copy] [--rvid=RVID]] dir1/file1 [[dir2/file2 [...]]"
  exit 1
}

set_server () {
  source "$sdir"/server.sh "$1"
}

declare -a fullURL=()
declare -A LINKTO
LOCALACTION="--copy-dest" #rsync option

while [[ ${1:-} =~ ^- ]]
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
    --snap=*|--snapshot=*)
        SNAP="${KEY#*=}"
    ;;
    --snap|--snapshot)
        SNAP=$1 && shift
    ;;
    -d|--dst)
      destination "$1" && shift
    ;;
    -d=*|--dst=*)
      destination "${KEY#*=}"
    ;;
    --rvid=*)
      declare argRVID="${KEY#*=}"
    ;;
    -s|--server)
      set_server "$1" && shift
    ;;
    -s=*|--server=*)
      set_server "${KEY#*=}"
    ;;
    --permissions)
      ACLS=1
    ;;
    --dry-run)
      options+=('--dry-run')
    ;;
    --no-owner)
      options+=( "--no-group" "--no-owner" )  
    ;;
    --delete)
      options+=( '--delete-delay' )
    ;;
    --local-copy)
      LOCALACTION="--copy-dest"
    ;;
    --local-link)
      LOCALACTION="--link-dest"
    ;;
    --link-dest=*)
      LINKTO["--link-dest=${KEY#*=}"]=1
    ;;
    --copy-dest=*)
      LINKTO["--copy-dest=${KEY#*=}"]=1
    ;;
    --no-local)
      unset LOCALACTION
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
    -h|--help)
        usage
    ;;
    -h=*|--help=*)
        usage "${KEY#*=}"
    ;;
    -- )
      while [[ $1 =~ ^- ]]
      do
        options+=("$1") && shift
      done
    ;;
    *)
      warn Unknown option $KEY && usage
    ;;
  esac
done

LINKS=( "${!LINKTO[@]}" )                 #get different link-dest/copy-dest
LINKS=( ${LINKS[@]+"${LINKS[@]:0:20}"} )  #a rsync limitation of 20 directories

[[ ${1+isset} == isset ]] || usage

declare -a RESOURCES=( "${@:-.}" )

mktempdir RESULT || die "Can't create a temporary working directory"

NOW="$(date +"%Y-%m-%dT%H-%M-%S-%Z-%a-%W")"
logfile="$VARDIR/log/restore/$NOW.log"
errfile="$VARDIR/log/restore/$NOW.err"
statsfile="$VARDIR/log/restore/$NOW.stat"

mkdir -pv "${logfile%/*}" "${errfile%/*}" "${statsfile%/*}" #Just ensure that the log directory exists

exec 3>&2
exec 2>"$errfile"

finish() {
	cat "$errfile" >&3
	[[ -s $errfile ]] || rm "$errfile"
  echo "Finish at $(date) with code $CODE"
}

atexit finish

aclparents(){
  local dest=$(readlink -e "$dest")
  local FILE=$(readlink -e "$dest/$FILE")
  until [[ $FILE == $dest ]]
  do
    FILE=$(readlink -e "$FILE") || break
    FILE=${FILE%/*} #parent
    PARENT="+FILE $(cygpath -w "$FILE")"
    ACLSOF["$PARENT"]=$(readlink -e "$CACHEDST/${FILE#$dest}/.bkit-dir-acl")
  done
}

NTFS_acls(){
  local SRC=$1
  local CACHEDST=$(readlink -mn "$2")
  local dest=$(readlink -e "$3")
  echo "Restore ACLs"
  [[ -d $CACHEDST ]] || mkdir -pv "$CACHEDST"
  rsync ${RSYNCOPTIONS+"${RSYNCOPTIONS[@]}"} -aizR --inplace ${perm+"${perm[@]}"} "$fmt" "$SRC" "$CACHEDST" ||
    warn "Problems while trying to restore $CACHEDST"
  {
    declare -A ACLSOF

    while read -r FILE
    do
      aclparents
      local TARGET=$(cygpath -w "$(readlink -e "$dest/$FILE")")
      ACLSOF["+FILE $TARGET"]=$(readlink -e "$CACHEDST/$FILE")
    done < <(grep -Pi 'recv\|[ch>.][^d].{9}\|' "$RESULT/index" | cut -d'|' -f3)

    while read -r FILE
    do
      aclparents
      local TARGET=$(cygpath -w "$(readlink -e "$dest/$FILE")")
      ACLSOF["+FILE $TARGET"]=$(readlink -e "$CACHEDST/$FILE/.bkit-dir-acl")
    done < <(grep -Pi 'recv\|.d.{9}\|' "$RESULT/index" | cut -d'|' -f3)

    for P in "${!ACLSOF[@]}"
    do
      echo -e "\n"
      echo $P
      cat "${ACLSOF["$P"]}"
    done
  } | iconv -f UTF-8 -t UTF-16LE > "$RESULT/acls"
  SUBINACL=$(find "$sdir/3rd-party" -type f -name "subinacl.exe" -print -quit)
  [[ -f $SUBINACL ]] || die SUBINACL.exe not found
  "$SUBINACL" /noverbose /nostatistic /playfile "$(cygpath -w "$RESULT/acls")"
  #"$SUBINACL" /nostatistic /playfile "$(cygpath -w "$RESULT/acls")"
}

makestats(){
  local DELTATIME=$1
  local ROOT=$2
  [[ ${STATS+isset} == isset && -e $logfile && -e "$sdir/lib/tools/stats/recv-stats.pl" ]] && exists perl && {
    echo "------------Stats------------"
    echo "Total time spent: $DELTATIME"
    exists cygpath && {
      ROOT=$(cygpath -w "$ROOT")
      ROOT="${ROOT//\\/\\\\}\\\\"
    }
    cat -v "$logfile" | grep -Pio '^".+"$' | awk -vA="$ROOT" 'BEGIN {FS = OFS = "|"} {print $1,$2,A $3,$4,$5,$6,$7}' | perl "$sdir/lib/tools/stats/recv-stats.pl"
    echo "------------End of Stats------------"
  } | tee "$statsfile"
}

source "$sdir/ccrsync.sh"
#Don't try to chown or chgrp if not root or Administrator
[[ $OS == cygwin ]] && {
    $(id -G|grep -qE '\b544\b') || options+=( "--no-group" "--no-owner" )
}
[[ $OS != cygwin && $UID -ne 0 ]] && options+=( "--no-group" "--no-owner" )

for RESOURCE in "${RESOURCES[@]}"
do
  if [[ $RESOURCE =~ ^[^@]+@.+::.+ ]] #ex: user@server::section
  then
    [[ -z $dest ]] && dest=${RESOURCES[${#RESOURCES[@]}-1]} && unset RESOURCES[${#RESOURCES[@]}-1] #Try to get last argument
    [[ -d $dest ]] || die "You should specify a (existing) destination directory in last argument or using --dst option"
    fullURL+=( "$RESOURCE" )		#Add to a list of multiple fullURL and dorsync later/bellow
    #dorsync "$RESOURCE" "$dest"
  else
    exists cygpath && RESOURCE="$(cygpath -u "$RESOURCE")"

    RESOURCE=$(readlink -m "${RESOURCE}")
    parentdir=$RESOURCE

    until [[ -d $parentdir ]]       #find a existing parent
    do
      parentdir=$(dirname "$parentdir") || parentdir="/"
    done

    ROOT=$(stat -c%m "$parentdir")

    BASE="${parentdir#${ROOT%%/}}"  #BASE is parentdir without the mounting point

    ENTRY=${RESOURCE#$parentdir}    #Is empty when resource is a existing directory (parentdir==RESOURCE)

    BASE=${BASE%%/}   #remove trailing slash if present. Yes, BASE could by a empty string
    ENTRY=${ENTRY#/}  #remove leading slash if present

    if [[ ${argRVID+isset} == isset ]] 
    then
      RVID="${argRVID}"
    else

      IFS='|' read -r VOLUMENAME VOLUMESERIALNUMBER FILESYSTEM DRIVETYPE <<<$("$sdir/lib/drive.sh" "$ROOT" 2>/dev/null)

      declare DRIVE=''
      exists cygpath && DRIVE=$(cygpath -w "$ROOT")
      DRIVE=${DRIVE%%:*}
      RVID="${DRIVE:-_}.${VOLUMESERIALNUMBER:-_}.${VOLUMENAME:-_}.${DRIVETYPE:-_}.${FILESYSTEM:-_}"
    fi

    [[ ${SNAP+isset} == isset ]] && { # if we want an older version
      SRC="$BACKUPURL/$RVID/.snapshots/$SNAP/data$BASE/./$ENTRY"
      METASRC="$BACKUPURL/$RVID/.snapshots/$SNAP/metadata$BASE/./$ENTRY"
    } || {              #or last version
      SRC="$BACKUPURL/$RVID/@current/data$BASE/./$ENTRY"
      METASRC="$BACKUPURL/$RVID/@current/metadata$BASE/./$ENTRY"
    }

    INIT=$(date -R)
    {
      if [[ ${dest+isset} == isset ]]
      then
        dorsync ${LINKS[@]+"${LINKS[@]}"} --no-relative ${LOCALACTION+"$LOCALACTION=$parentdir/"} "$SRC" "$dest" | tee "$RESULT/index" || warn "Problems restoring to $dest"
      else
        dorsync ${LINKS[@]+"${LINKS[@]}"} "$SRC" "$parentdir/" | tee "$RESULT/index" || warn "Problems restoring the $BASE/$ENTRY"
      fi
      [[ ${ACLS+isset} == isset && $OS == 'cygwin' && $FILESYSTEM == 'NTFS' ]] && (id -G|grep -qE '\b544\b') && (
        NTFS_acls "$METASRC" "$sdir/cache/metadata/by-volume/${VOLUMESERIALNUMBER:-_}$BASE/" "${dest:-$parentdir}"
      )
    } | tee "$logfile"
    STOP=$(date -R)
    deltatime "$STOP" "$INIT"
    makestats "$DELTATIME" "${dest:-$parentdir}"
  fi
done

[[ ${dest+isset} == isset && ${#fullURL[@]} -gt 0 ]] && {	
  #if SRC(s) in format user@server::section (this is for migration)
  set -o pipefail
  INIT=$(date -R)
  dorsync ${LINKS[@]+"${LINKS[@]}"} "${fullURL[@]}" "$dest" | tee "$logfile" || die "Problems restoring to $dest"
  exists cygpath && dest=$(cygpath -w "$dest")
  echo "Files restored to $dest"
  STOP=$(date -R)
  deltatime "$STOP" "$INIT"
  makestats "$DELTATIME" "$dest"
}

[[ ${NOTIFY+isset} == isset && -s $statsfile ]] && (
  ME=$(uname -n)
  FULLDIRS=( $(readlink -e "${RESOURCES[@]}") )     #get full paths
  exists cygpath &&  FULLDIRS=( $(cygpath -w "${FULLDIRS[@]}") )
  printf -v DIRS "%s, " "${FULLDIRS[@]}"
  DIRS=${DIRS%, }
  WHAT=$DIRS
  let NUMBEROFDIRS=${#FULLDIRS[@]}
  let LIMIT=3
  let EXTRADIRS=NUMBEROFDIRS-LIMIT
  ((NUMBEROFDIRS > LIMIT)) && WHAT="${FULLDIRS[0]} and $EXTRADIRS more directories/files"
  [[ -n $dest ]] && exists cygpath && dest=$(cygpath -w "$dest")
  [[ -s $errfile ]] && SUBJECT="Some errors occurred while restoring $WHAT on $ME ${dest:+to $dest} at $(date +%Hh%Mm)" ||
  SUBJECT="Restore of $WHAT ${dest:+to $dest} on $ME successfully finished at $(date +%Hh%Mm)"
  {
    echo "Restore of $DIRS"
    cat "$statsfile"

    [[ -s $errfile ]] && {
      echo -e "\n------------Errors found------------"
      cat "$errfile"
      echo "------------End of Errors------------"
    }

    [[ -n $FULLREPORT ]] && {
      echo -e "\n------------Full Logs------------"
      cat "$logfile"
      echo "------------End of Logs------------"
    }
  } | sendnotify "$SUBJECT" "$ME" "$DEST"
)

echo "Restore done in $DELTATIME"
exit ${ERROR:-0}
