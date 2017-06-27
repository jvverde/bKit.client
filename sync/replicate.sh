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
PREFIX=$(head -n1 "$HASHFILE"|cut -d '|' -f4|cut -d '/' -f1)
RVID=$(echo $HASHFILE | perl "$SDIR/perl/get-RVID.pl")
SECTION="$(echo $HASHFILE | perl "$SDIR/perl/get-SECTION.pl")"
BACKUPURL="rsync://user@$SERVER:$PORT/$SECTION"
NEWREPO=${SECTION//.//}
BASE="${HASHFILE%/hashes/file}/$PREFIX"

bash "$SDIR/compare.sh" --backupurl="$BACKUPURL" --rvid="$RVID" "$REPO" 2>/dev/null 2>/dev/null || {
	bash "$SDIR/newrepo.sh" "$SERVER" "$NEWREPO" &&
	bash "$SDIR/send-manifest.sh" --backupurl="$BACKUPURL" --rvid="$RVID" --prefix="$PREFIX" "$HASHFILE" &&
	bash "$SDIR/send-seed.sh" --backupurl="$BACKUPURL" --rvid="$RVID" --prefix="$PREFIX" --base="$BASE" "$HASHFILE" &&
	bash "$SDIR/update-dirs.sh" --backupurl="$BACKUPURL" --rvid="$RVID" "$REPO" &&
	bash "$SDIR/snap-now.sh" --backupurl="$BACKUPURL" --rvid="$RVID" "$REPO" &&
	echo Replication done
}
