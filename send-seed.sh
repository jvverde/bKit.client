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
    --base=*)
      BASE="${KEY#*=}"
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

BACKUPURL=${BACKUPURL%/}
RVID=${RVID%/}

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

RUNDIR="$SDIR/run"
[[ -d $RUNDIR ]] || mkdir -p "$RUNDIR"

export RSYNC_PASSWORD="$(cat "$SDIR/conf/pass.txt")"

update_file(){
	dorsync -tiz --inplace "${PERM[@]}" $FMT "$@"
}

update_files(){
  local SRC=$1 && shift
  local FILE="$RUNDIR/$$.sort"
  LC_ALL=C sort -o "$FILE" "$SRC"
  dorsync --archive --inplace --hard-links --relative --files-from="$FILE" --itemize-changes "${PERM[@]}" $FMT "$@"
  rm -f "$FILE"
}

upload_seed(){
  local SEED="$1"
  local BASE="$2"
  local PREFIX="${3:-data}"
  local FILES="$RUNDIR/$$.seedfiles"

  cut -d'|' -f4- "$SEED" > "$FILES"

  echo update_files "$FILES" "$BASE" "$BACKUPURL/$RVID/@seed/$PREFIX"
  echo update_file "$SEED" "$BACKUPURL/$RVID/@apply-seed/$PREFIX/manifest.lst"
  rm -f "$FILES"
}

[[ -z $PREFIX ]] && {
	PREFIX=$(head -n1 "$1"|cut -d '|' -f4|cut -d '/' -f1)
}
[[ -z $BASE ]] && {
  BASE="${1%/hashes/file}/$PREFIX"
}
[[ -z $RVID ]] && {
	RVID=$(echo $1 | perl -lane 'print (m#/data/((?:[^/]+\.){4}[^/]+)/(?=@|.snapshots/@)#);')
}
[[ -z $BACKUPURL && -n $SERVER && -n $PORT ]] && {
	BACKUPURL="rsync://$SERVER:$PORT/$(echo $1 | perl -lane '$,=q|.|;print (m#/([^/]+)/([^/]+)/([^/]+)/data/(?:.+\.){4}[^/]+/(?=@|.snapshots/@)#);')"
}

HASHFILE="$RUNDIR/$$.hashes"

perl -F'\|' -slane  '{$F[3] =~ s#^$prefix/##; print "$F[0]|$F[1]|$F[2]|$F[3]"}' -- -prefix=$PREFIX "$1" > $HASHFILE

[[ -z $BACKUPURL || -z $RVID || -z $BASE || -z $PREFIX ]] && {
	die "Usage:\n\t $(basename -s .sh "$0") --backupurl=rsync://server:port/domain.host.uuid [--rvid=letter.uuid.label.type.fs] [--base=base] [--prefix=prefix] hashfile"
}

upload_seed "$HASHFILE" "$BASE" "$PREFIX"
rm -rf "$HASHFILE"
