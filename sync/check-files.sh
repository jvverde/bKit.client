#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH

SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR

source "$SDIR/../functions/all.sh"

OS=$(uname -o |tr '[:upper:]' '[:lower:]')


RSYNCOPTIONS=()
PORT=8731

while [[ $1 =~ ^- ]]
do
	KEY="$1" && shift
	case "$KEY" in
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


exists rsync || die Cannot find rsync


dorsync(){
	rsync "${RSYNCOPTIONS[@]}" --one-file-system --compress "$@"
}

FMT='--out-format="%o|%i|%f|%c|%b|%l|%t"'

export RSYNC_PASSWORD="$(cat "$SDIR/../conf/pass.txt")"

check_snap(){
	dorsync --list-only $FMT "$@"
}

[[ -z $RVID ]] && {
  RVID=$(echo $1 | perl -lane 'print (m#/data/((?:[^/]+\.){4}[^/]+/(?:@.+$|[.]snapshots/?$|[.]snapshots/@.+$|$))#);')
}
[[ -z $BACKUPURL && -n $SERVER && -n $PORT ]] && {
  BACKUPURL="rsync://user@$SERVER:$PORT/$(echo $1 | perl -lane '$,=q|.|;print (m#/([^/]+)/([^/]+)/([^/]+)/data/(?:.+\.){4}[^/]+/(?:@.+$|[.]snapshots/?$|[.]snapshots/@.+$|$)#);')"
}

check_snap "$BACKUPURL/$RVID"
