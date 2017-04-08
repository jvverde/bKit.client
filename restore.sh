#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"       #Full DIR
OS=$(uname -o |tr '[:upper:]' '[:lower:]')

set -o pipefail

exists() { type "$1" >/dev/null 2>&1;}
die() { echo -e "$@" >&2; exit 1;}
warn() { echo -e "$@" >&2;}

export RSYNC_PASSWORD="$(cat "$SDIR/conf/pass.txt")"

FMT='--out-format=%o|%i|%b|%l|%f|%M|%t'
PERM=(--perms --acls --owner --group --super --numeric-ids)
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
)

RSYNCOPTIONS=()

dorsync() {
  local BACKUP="${@: -1}$BACKUPDIR"
  mkdir -p "$BACKUP"
  rsync "${RSYNCOPTIONS[@]}" "${PERM[@]}" "$FMT" "${OPTIONS[@]}" "$@"
  find "$BACKUP" -maxdepth 0 -empty -delete 2>/dev/null
  [[ -e "$BACKUP" ]] && {
    exists cygpath && BACKUP=$(cygpath -w "$BACKUP")
    echo Old files saved on "$BACKUP"
  }
}

destination() {
  DST="$1"
  exists cygpath && DST=$(cygpath -u "$DST")
  DST=$(readlink -ne "$DST") || die "'$1' should be a directory"
  [[ ${DST: -1} == / ]] || DST="$DST/"

  #Don't try to chown or chgrp if not root or Administrator
  [[ $OS == cygwin ]] && {
      $(id -G|grep -qE '\b544\b') || OPTIONS+=( "--no-group" "--no-owner" )
  }
  [[ $OS != cygwin && $UID -ne 0 ]] && OPTIONS+=( "--no-group" "--no-owner" )
}

usage() {
  local NAME=${1:$(basename -s .sh "$0")}
  echo Restore from backup one or more directories of files
  echo -e "Usage:\n\t $NAME [--delete] [--dst=directory] [--snap=snap] [--local-copy] dir1/file1 [[dir2/file2 [...]]"
  exit 1
}

LOCALCOPY="--link-dest" #rsync option
while [[ $1 =~ ^- ]]
do
  KEY="$1" && shift
  case "$KEY" in
    -s|--snap|--snapshot)
        SNAP=$1 && shift
    ;;
    -s=*|--snap*=|--snapshot=*)
        SNAP="${KEY#*=}"
    ;;
    -d|--dst)
      destination "$1" && shift
    ;;
    -d=*|--dst=*)
      destination "${KEY#*=}"
    ;;
    --delete)
        OPTIONS+=( '--delete-delay' )
    ;;
    --local-copy)
      LOCALCOPY="--copy-dest"
    ;;
    -- )
      while [[ $1 =~ ^- ]]
      do
        RSYNCOPTIONS+=("$1") && shift
      done
    ;;
    -h|--help)
        usage
    ;;
    -h=*|--help=*)
        usage "${KEY#*=}"
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

SRCS=()
declare -A LINKTO

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
      SRCS+=( "$SRC" ) #In case we are importing all srcs to a single locatuion, do it later, all in one single rsync call
      LINKTO["$LOCALCOPY=$DIR/"]=1
    else
      dorsync "$SRC" "$DIR/" | tee "$RESULT/index" || warn "Problems restoring the $BASE/$ENTRY"

      [[ $OS == 'cygwin' && $FILESYSTEM == 'NTFS' ]] && (id -G|grep -qE '\b544\b') && (
        METADATADST=$SDIR/cache/metadata/by-volume/${VOLUMESERIALNUMBER:-_}$BASE/
        [[ -d $METADATADST ]] || mkdir -pv "$METADATADST"
        rsync "${RSYNCOPTIONS[@]}" -aizR --inplace "${PERM[@]}" "${PERM[@]}" "$FMT" "$METASRC" "$METADATADST" ||
          warn "Problemas ao recuperar $METADATADST/$BASE/"
        DRIVE=$(cygpath -w "$ROOT")
        : > "$RESULT/acls"
        cat "$RESULT/index"|grep 'recv[|][.>]f'|cut -d'|' -f5|
        while read FILE
        do
          ACLFILE=$(dirname "$METADATADST$FILE")/.bkit-acls
          echo $ACLFILE
          iconv -f UTF-16LE -t UTF-8 "$ACLFILE" |
            sed -E 's#^\+File [A-Z]:#+File '${DRIVE:0:1}':#i' |
            iconv  -f UTF-8 -t UTF-16LE >> "$RESULT/acls"
          cat
        done
        [[ -s "$RESULT/acls" ]] && {
          echo 'Apply ACLS now'
          bash "$SDIR/applyacls.sh" "$RESULT/acls"
        }
      )
    fi
  fi
done

[[ -n $DST && ${#SRCS[@]} -gt 0 ]] && {
  LINKS=( "${!LINKTO[@]}" )                   #get different link-dest/copy-dest
  FIRST20=( "${LINKS[@]:0:20}" )              #a rsync limitation
  dorsync "${FIRST20[@]}" "${SRCS[@]}" "$DST"
  exists cygpath && DST=$(cygpath -w "$DST")
  echo "Files restored to $DST"
}
