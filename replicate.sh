#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH

SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR

source "$SDIR/functions/all.sh"

OS=$(uname -o |tr '[:upper:]' '[:lower:]')


RSYNCOPTIONS=(
  --groupmap=4294967295:$(id -u)
  --usermap=4294967295:$(id -g)
  --numeric-ids
)
PORT=8731

while [[ $1 =~ ^- ]]
do
	KEY="$1" && shift
	case "$KEY" in
    --server)
      SERVER="$1" && shift
    ;;
    --server=*)
      SERVER="${KEY#*=}"
    ;;
    --port)
      PORT="$1" && shift
    ;;
    --port=*)
      PORT="${KEY#*=}"
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

HASHFILE="$1"
[[ $HASHFILE =~ /hashes/file$ ]] || die "Invalid location for a hash file"
PREFIX=$(head -n1 "$HASHFILE"|cut -d '|' -f4|cut -d '/' -f1)
RVID=$(echo $HASHFILE | perl -lane 'print (m#/data/((?:[^/]+\.){4}[^/]+)/(?=@|.snapshots/@)#);')
SECTION="$(echo $HASHFILE | perl -lane '$,=q|.|;print (m#/([^/]+)/([^/]+)/([^/]+)/data/(?:.+\.){4}[^/]+/(?=@|.snapshots/@)#);')"
BACKUPURL="rsync://user@$SERVER:$PORT/$SECTION"
REPO=${SECTION//.//}
BASE="${HASHFILE%/hashes/file}/$PREFIX"

"$SDIR/newrepo.sh" "$SERVER" "$REPO" 
"$SDIR/send-manifest.sh" --backupurl="$BACKUPURL" --rvid="$RVID" --prefix="$PREFIX" "$HASHFILE" 
"$SDIR/send-seed.sh" --backupurl="$BACKUPURL" --rvid="$RVID" --prefix="$PREFIX" --base="$BASE" "$HASHFILE"
