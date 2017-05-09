#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"       #Full DIR
OS=$(uname -o |tr '[:upper:]' '[:lower:]')

set -o pipefail
ERROR=0

exists() { type "$1" >/dev/null 2>&1;}
die() { echo -e "$@" >&2; exit 1;}
warn() {
  ERROR=1
  echo -e "$@" >&2
}

export RSYNC_PASSWORD="$(cat "$SDIR/conf/pass.txt")"

FMT='--out-format=%o|%i|%b|%l|%f|%M|%t'
PERM=(--perms --acls --super --numeric-ids)
BACKUP=".bkit-before-restore-on"
BACKUPDIR="$BACKUP-$(date +"%Y-%m-%dT%H-%M-%S")"
while [[ -e $BACKUPDIR ]]
do
  BACKUPDIR="${BACKUPDIR}_"
done

OPTIONS=(
  --backup
  --backup-dir="$BACKUPDIR"
  --archive
  --exclude="${BACKUP}*"
  --hard-links
  --compress
  --human-readable
  --relative
  --partial
  --partial-dir=".bkit.rsync-partial"
  --delay-updates
  --groupmap=4294967295:$(id -u)
  --usermap=4294967295:$(id -g)
  --numeric-ids
)

#Don't try to chown or chgrp if not root or Administrator

[[ $OS == cygwin ]] && {
    $(id -G|grep -qE '\b544\b') || OPTIONS+=( "--no-group" "--no-owner" )
}
[[ $OS != cygwin && $UID -ne 0 ]] && OPTIONS+=( "--no-group" "--no-owner" )

RSYNCOPTIONS=()

dorsync() {
  local BACKUP="${@: -1}$BACKUPDIR"
  mkdir -p "$BACKUP"
  rsync "${RSYNCOPTIONS[@]}" "${PERM[@]}" "$FMT" "${OPTIONS[@]}" "$@"
  RET=$?
  find "$BACKUP" -maxdepth 0 -empty -delete 2>/dev/null
  [[ -e "$BACKUP" ]] && {
    exists cygpath && BACKUP=$(cygpath -w "$BACKUP")
    echo Old files saved on "$BACKUP"
  }
  return $RET
}

destination() {
  DST="$1"
  exists cygpath && DST=$(cygpath -u "$DST")
  DST=$(readlink -ne "$DST") || die "'$1' should be a directory"
  [[ ${DST: -1} == / ]] || DST="$DST/"
}

usage() {
  local NAME=${1:-"$(basename -s .sh "$0")"}
  echo -e "Usage:\n\t $NAME [--dry-run] [--permissions] [--delete] [--dst=directory] [--snap=snap] [--local-copy] dir1/file1 [[dir2/file2 [...]]"
  exit 1
}

SRCS=()
declare -A LINKTO
LOCALACTION="--link-dest" #rsync option
while [[ $1 =~ ^- ]]
do
  KEY="$1" && shift
  case "$KEY" in
    -s=*|--snap=*|--snapshot=*)
        SNAP="${KEY#*=}"
    ;;
    -s|--snap|--snapshot)
        SNAP=$1 && shift
    ;;
    -d|--dst)
      destination "$1" && shift
    ;;
    -d=*|--dst=*)
      destination "${KEY#*=}"
    ;;
    --permissions)
      ACLS=1
    ;;
    --dry-run)
      RSYNCOPTIONS+=('--dry-run')
    ;;
    --delete)
      OPTIONS+=( '--delete-delay' )
    ;;
    --local-copy)
      LOCALACTION="--copy-dest"
    ;;
    --link-dest=*)
      LINKTO["--link-dest=${KEY#*=}"]=1
    ;;
    --copy-dest=*)
      LINKTO["--copy-dest=${KEY#*=}"]=1
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
        RSYNCOPTIONS+=("$1") && shift
      done
    ;;
    *)
      warn Unknown option $KEY && usage
    ;;
  esac
done

RESOURCES=("$@")

CONF=$SDIR/conf/conf.init
[[ -f $CONF ]] || die Cannot found configuration file at $CONF
. "$CONF"                                                                     #get configuration parameters

RESULT="$SDIR/run/restore-$$/"
trap "rm -rf '$RESULT'" EXIT
mkdir -p "$RESULT"

NTFS_acls(){
  local SRC=$1
  local CACHEDST=$2
  local DST=$3
  echo "Restore ACLs"
  [[ -d $CACHEDST ]] || mkdir -pv "$CACHEDST"
  rsync "${RSYNCOPTIONS[@]}" -aizR --inplace "${PERM[@]}" "${PERM[@]}" "$FMT" "$SRC" "$CACHEDST" ||
    warn "Problemas ao recuperar $CACHEDST"
  {
    grep -Pi 'recv\|[>.][^d].{9}\|' "$RESULT/index" | cut -d'|' -f5|
    while read -r FILE
    do
      echo -e "\n"
      echo "+FILE $(cygpath -w "$DST/$FILE")"
      cat "$CACHEDST/$FILE"
    done
    grep -Pi 'recv\|.d.{9}\|' "$RESULT/index" | cut -d'|' -f5|
    while read -r FILE
    do
      echo -e "\n"
      echo "+FILE $(cygpath -w "$DST/$FILE")"
      cat "$CACHEDST/$FILE/.bkit-dir-acl"
    done
  }| iconv -f UTF-8 -t UTF-16LE > "$RESULT/acls"
  SUBINACL=$(find "$SDIR/3rd-party" -type f -name "subinacl.exe" -print -quit)
  [[ -f $SUBINACL ]] || die SUBINACL.exe not found
  "$SUBINACL" /playfile "$(cygpath -w "$RESULT/acls")"
}

for RESOURCE in "${RESOURCES[@]}"
do
  if [[ $RESOURCE =~ ^rsync://[^@]+@ ]]
  then
    [[ -z $DST ]] && DST=${RESOURCES[${#RESOURCES[@]}-1]} && unset RESOURCES[${#RESOURCES[@]}-1] #get last argument
    [[ -d $DST ]] || die "You should specify a (existing) destination directory in last argument or using --dst option"
    SRCS+=( "$RESOURCE" )
    #dorsync "$RESOURCE" "$DST"
  else
    exists cygpath && RESOURCE="$(cygpath -u "$RESOURCE")"
    RESOURCE=$(readlink -m "${RESOURCE}")
    DIR=$RESOURCE
    until [[ -d $DIR ]]       #find a existing parent
    do
      DIR=$(dirname "$DIR")
    done

    ROOT=$(stat -c%m "$DIR")

    BASE="${DIR#${ROOT%%/}}"

    ENTRY=${RESOURCE#$DIR}    #Is empty when resource is a existing directory (DIR==RESOURCE)

    IFS='|' read -r VOLUMENAME VOLUMESERIALNUMBER FILESYSTEM DRIVETYPE <<<$("$SDIR/drive.sh" "$ROOT" 2>/dev/null)

    exists cygpath && DRIVE=$(cygpath -w "$ROOT")
    DRIVE=${DRIVE%%:*}
    RVID="${DRIVE:-_}.${VOLUMESERIALNUMBER:-_}.${VOLUMENAME:-_}.${DRIVETYPE:-_}.${FILESYSTEM:-_}"
    BASE=${BASE%%/}   #remove trailing slash if present
    ENTRY=${ENTRY#/}  #remove leading slash if present

    [[ -n $SNAP ]] && { # if we want an older version
      SRC="$BACKUPURL/$RVID/.snapshots/$SNAP/data$BASE/./$ENTRY"
      METASRC="$BACKUPURL/$RVID/.snapshots/$SNAP/metadata$BASE/./$ENTRY"
    } || {              #or last version
      SRC="$BACKUPURL/$RVID/@current/data$BASE/./$ENTRY"
      METASRC="$BACKUPURL/$RVID/@current/metadata$BASE/./$ENTRY"
    }

    if [[ -n $DST ]]
    then
      dorsync "$SRC" "$LOCALACTION=$DIR/" "$DST/" | tee "$RESULT/index" || warn "Problems restoring to $ST"
    else
      dorsync "$SRC" "$DIR/" | tee "$RESULT/index" || warn "Problems restoring the $BASE/$ENTRY"
    fi
    [[ -n $ACLS && $OS == 'cygwin' && $FILESYSTEM == 'NTFS' ]] && (id -G|grep -qE '\b544\b') && (
      NTFS_acls "$METASRC" "$SDIR/cache/metadata/by-volume/${VOLUMESERIALNUMBER:-_}$BASE/" "${DST:-$DIR}"
    )
  fi
done

[[ -n $DST && ${#SRCS[@]} -gt 0 ]] && {
  LINKS=( "${!LINKTO[@]}" )                   #get different link-dest/copy-dest
  FIRST20=( "${LINKS[@]:0:20}" )              #a rsync limitation
  dorsync "${FIRST20[@]}" "${SRCS[@]}" "$DST" || die "Problems restoring to $DST"
  exists cygpath && DST=$(cygpath -w "$DST")
  echo "Files restored to $DST"
  exit 0
}

exit $ERROR
