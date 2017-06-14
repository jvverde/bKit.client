#!/bin/bash
SDIR=$(dirname "$(readlink -f "$0")")	#Full SDIR

SECTION=bkit
PORT=8730

source "$SDIR/functions/all.sh"

while [[ $1 =~ ^- ]]
do
  KEY="$1" && shift
  case "$KEY" in
    --section)
      SECTION="$1" && shift
    ;;
    --section=*)
      SECTION="${KEY#*=}"
    ;;
    --port)
      PORT="$1" && shift
    ;;
    --port=*)
      PORT="${KEY#*=}"
    ;;
    *)
      die Unknown option $KEY
    ;;
  esac
done

SERVER="$1"
REPO="$2"
#${DOMAIN}/${NAME}/${UUID}

exists rsync || die rsync not found

export RSYNC_PASSWORD="4dm1n"
FMT='--out-format="%o|%i|%f|%c|%b|%l|%t"'

rsync --dry-run $FMT "$SDIR/./" "rsync://admin@${SERVER}:${PORT}/${SECTION}/$REPO"
RET=$?
[[ $RET -ne 0 ]] && die "Exit value of rsync is non null: $RET"

echo "Repo setup successfully!"
