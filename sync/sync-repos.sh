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
OPTIONS=()
PORT=8731
while [[ $1 =~ ^- ]]
do
	KEY="$1" && shift
	case "$KEY" in
		--snap)
			SNAP="$1" && shift
		;;
		--snap=*)
			SNAP="${KEY#*=}"
		;;
		--reverse)
			let REVERSE=1
		;;
		--list-only)
			let REVERSE=2
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
			OPTIONS+=( "$KEY" )
		;;
	esac
done

BACKUPURL=${BACKUPURL%/}
RVID=${RVID%/}

exists rsync || die Cannot find rsync


dorsync(){
	local RETRIES=100
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
				die "Fail to backup. Exit value of rsync is non null: $ret"
				break
			;;
		esac
		(( --RETRIES < 0 )) && warn "I'm tired of trying" && break
	done
}

REPO="$1"

FMT='--out-format="%o|%i|%f|%c|%b|%l|%t"'
PERM=(--perms --acls --owner --group --super --numeric-ids)

export RSYNC_PASSWORD="$(cat "$SDIR/../conf/pass.txt")"

doit(){
	[[ ${#OPTIONS[@]} -eq 0 ]] && OPTIONS=( '--dry-run' '-rltiR')
	dorsync "${OPTIONS[@]}" "${PERM[@]}" $FMT "$@"
}

[[ -z $RVID ]] && {
	RVID=$(echo $REPO | perl -lane 'print (m#/data/((?:[^/]+\.){4}[^/]+)/(?=@|[.]snapshots/@)#);')
}
[[ -z $SNAP ]] && {
	SNAP=$(echo $REPO | perl -lane 'print (m#/data/(?:[^/]+\.){4}[^/]+/(@[^/]+|[.]snapshots/@[^/]+)#);')
}
[[ -z $BACKUPURL && -n $SERVER && -n $PORT ]] && {
	BACKUPURL="rsync://user@$SERVER:$PORT/$(echo $REPO | perl -lane '$,=q|.|;print (m#/([^/]+)/([^/]+)/([^/]+)/data/(?:.+\.){4}[^/]+/(?=@|.snapshots/@)#);')"
}

[[ -z $REPO || -z $BACKUPURL || -z $RVID  ]] && {
	echo REPO=$REPO
	echo BACKUPURL=$BACKUPURL
	echo RVID=$RVID
	echo SERVER=$SERVER
	die "Usage:\n\t $(basename -s .sh "$0") [--reverse|--list-only] --backupurl=rsync://user@server:port/domain.host.uuid [--rvid=letter.uuid.label.type.fs] snapdir"
}

SRC=$(echo $REPO|sed -E 's#(/data/([^/.]+\.){4}[^/]+/(@|.snapshots/@)[^/]+)/?#\1/./#;')
DST=$(echo "$BACKUPURL/$RVID/$SNAP"|sed -E 's#(/([^/.]+\.){4}[^/]+/(@|.snapshots/@)[^/]+)/?#\1/./#;')

[[ -z ${REVERSE:+isset} ]] && {
	[[ $SNAP =~ ^@ ]] || die "We cannot use $DST as destination. Use --reverse or --list-only options"
	doit  "$SRC" "$DST"
}
(( REVERSE == 1 )) && doit  "$DST" "$SRC"
(( REVERSE == 2 )) && doit  --list-only "$DST"
