#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH

SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR

source "$SDIR/../functions/all.sh"

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
    --base)
      BASE="$1" && shift
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

BACKUPURL=${BACKUPURL%/}
RVID=${RVID%/}

exists rsync || die Cannot find rsync


dorsync(){
	local RETRIES=1000
	while true
	do
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

SNAP="$1"
FMT='--out-format="%o|%i|%f|%c|%b|%l|%t"'
PERM=(--perms --acls --owner --group --super --numeric-ids)

RUNDIR="$SDIR/run/seed-$$"
[[ -d $RUNDIR ]] || mkdir -p "$RUNDIR"
trap 'rm -rf "$RUNDIR"' EXIT

export RSYNC_PASSWORD="$(cat "$SDIR/../conf/pass.txt")"

check(){
	dorsync --ignore-non-existing --ignore-existing -rtizR "${PERM[@]}" $FMT "$@"
}

[[ -z $RVID ]] && {
	RVID=$(echo $SNAP | perl -lane 'print (m#/data/((?:[^/]+\.){4}[^/]+)/(?=@|.snapshots/@)#);')
}
[[ -z $BACKUPURL && -n $SERVER && -n $PORT ]] && {
	BACKUPURL="rsync://user@$SERVER:$PORT/$(echo $SNAP | perl -lane '$,=q|.|;print (m#/([^/]+)/([^/]+)/([^/]+)/data/(?:.+\.){4}[^/]+/(?=@|.snapshots/@)#);')"
}

[[ -z $BACKUPURL || -z $RVID  ]] && {
	die "Usage:\n\t $(basename -s .sh "$0") --backupurl=rsync://user@server:port/domain.host.uuid [--rvid=letter.uuid.label.type.fs] [--base=base] [--prefix=prefix] hashfile"
}

SRC=$(echo $SNAP|sed -E 's#(/data/([^/.]+\.){4}[^/]+/(@|.snapshots/@)[^/]+)/?#\1/./#;')

check  "$SRC" "$BACKUPURL/$RVID/@current/"
