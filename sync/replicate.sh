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

HASHFILE="$REPO/hashes/file"
[[ -e $HASHFILE ]] || die "Didn't find a hash file"
[[ -z $SERVER ]] && SERVER="$2" 
[[ -z $SERVER ]] && Usage

RVID=$(echo $HASHFILE | perl "$SDIR/perl/get-RVID.pl")
SECTION="$(echo $HASHFILE | perl "$SDIR/perl/get-SECTION.pl")"
BACKUPURL="rsync://user@$SERVER:$PORT/$SECTION"

LOGDIR="$SDIR/../logs/sync/$SECTION/$RVID"
[[ -d $LOGDIR ]] || mkdir -p "$LOGDIR"
NOW="$(date --iso-8601=seconds)"
BN="$(basename "$REPO")"
LOGFILE="$LOGDIR/$BN.log.$NOW"
LOGERR="$LOGDIR/$BN.err.$NOW"
echo "Logs goes to $LOGFILE and errors to $LOGERR"
exec 1>"$LOGFILE"
exec 2>"$LOGERR"

echo "Start compare $REPO on server $SERVER"

NEWREPO=${SECTION//.//}
bash "$SDIR/newrepo.sh" "$SERVER" "$NEWREPO" 

bash "$SDIR/compare.sh" --backupurl="$BACKUPURL" --rvid="$RVID" "$REPO" || {
	echo "It seems doesn't exist. I am going to sync it"
	while read -r PREFIX
	do
		BASE="${HASHFILE%/hashes/file}/$PREFIX"
		bash "$SDIR/send-manifest.sh" --backupurl="$BACKUPURL" --rvid="$RVID" --prefix="$PREFIX" "$HASHFILE"
		bash "$SDIR/send-seed.sh" --backupurl="$BACKUPURL" --rvid="$RVID" --prefix="$PREFIX" --base="$BASE" "$HASHFILE" 
	done < <(cut -d'|' -f4 "$HASHFILE"|cut -d'/' -f1 |sed /^$/d |sort -u)
	bash "$SDIR/clean.sh" --backupurl="$BACKUPURL" --rvid="$RVID" "$REPO" 
	bash "$SDIR/update-dirs.sh" --backupurl="$BACKUPURL" --rvid="$RVID" "$REPO" 
	bash "$SDIR/snap-now.sh" --backupurl="$BACKUPURL" --rvid="$RVID" "$REPO" 
	echo Replication done
}
echo "Done compare $REPO on server $SERVER"
