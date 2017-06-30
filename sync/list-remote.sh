#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH

SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR

source "$SDIR/../functions/all.sh"

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

Usage(){
	die "Usage :\n\t $(basename -s .sh "$0") local-repo remote-server"
}

REPO="$1"

[[ -d $REPO ]] || Usage

[[ -z $SERVER ]] && SERVER="$2" 
[[ -z $SERVER ]] && Usage

SECTION="$(echo $REPO | perl "$SDIR/perl/get-SECTION.pl")"
RVID=$(echo $REPO | perl "$SDIR/perl/get-RVID.pl")
BACKUPURL="rsync://user@$SERVER:$PORT/$SECTION"
[[ -n $RVID ]] && SUBDIR=${REPO#*$RVID}
SUBDIR=${SUBDIR#/}

export RSYNC_PASSWORD="$(cat "$SDIR/../conf/pass.txt")"

rsync --list-only "$BACKUPURL/$RVID/$SUBDIR"
