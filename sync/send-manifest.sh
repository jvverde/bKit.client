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
    --prefix)
      PREFIX="$1" && shift
    ;;
    --prefix=*)
      PREFIX="${KEY#*=}"
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


dorsync2(){
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

dorsync(){
	dorsync2 "$@" | grep -v 'unpack_smb_acl'
}

FMT='--out-format="%o|%i|%f|%c|%b|%l|%t"'
PERM=(--perms --acls --owner --group --super --numeric-ids)

RUNDIR="$SDIR/run/manifest-$$"
[[ -d $RUNDIR ]] || mkdir -p "$RUNDIR"
trap 'rm -rf "$RUNDIR"' EXIT
MANIF="$RUNDIR/manifest-$$"

export RSYNC_PASSWORD="$(cat "$SDIR/../conf/pass.txt")"

update_file(){
	dorsync -tiz --inplace "${PERM[@]}" $FMT "$@"
}

upload_manifest(){
  	local MANIFEST="$1"
  	local PREFIX="${2:-data}"
	update_file "$MANIFEST" "$BACKUPURL/$RVID/@manifest/$PREFIX/manifest.lst"
	update_file "$MANIFEST" "$BACKUPURL/$RVID/@apply-manifest/$PREFIX/manifest.lst"
}

[[ -z $PREFIX ]] && {
  PREFIX=$(head -n1 "$1"|cut -d '|' -f4|cut -d '/' -f1)
}
[[ -z $RVID ]] && {
  RVID=$(echo $1 | perl -lane 'print (m#/data/((?:[^/]+\.){4}[^/]+)/(?=@|.snapshots/@)#);')
}
[[ -z $BACKUPURL && -n $SERVER && -n $PORT ]] && {
  BACKUPURL="rsync://user@$SERVER:$PORT/$(echo $1 | perl -lane '$,=q|.|;print (m#/([^/]+)/([^/]+)/([^/]+)/data/(?:.+\.){4}[^/]+/(?=@|.snapshots/@)#);')"
}


sed /^$/d "$1" | perl -F'\|' -slane  '{$F[3] =~ s#^$prefix/##; print "$F[0]|$F[1]|$F[2]|$F[3]"}' -- -prefix=$PREFIX > "$MANIF"

upload_manifest  "$MANIF" "$PREFIX" 

