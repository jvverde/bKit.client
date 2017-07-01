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
	--no-log)
		NOLOG=1
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

[[ -z ${NOLOG:+unset} ]]  && {
	LOGDIR="$SDIR/../logs/sync/$SECTION/$RVID"
	[[ -d $LOGDIR ]] || mkdir -p "$LOGDIR"
	NOW="$(date --iso-8601=seconds)"
	BN="$(basename "$REPO")"
	LOGFILE="$LOGDIR/${BN}_$NOW.log"
	LOGERR="$LOGDIR/${BN}_$NOW.err"
	echo "Logs goes to $LOGFILE and errors to $LOGERR"
	exec 1>"$LOGFILE"
	exec 2>"$LOGERR"
}

RUNDIR="$SDIR/../run/replicate-$$"
[[ -d $RUNDIR ]] || mkdir -p "$RUNDIR"
trap 'rm -rf "$RUNDIR"' EXIT
MANIF="$RUNDIR/hashes"

echo "Start compare $REPO on server $SERVER"

bash "$SDIR/list-remote.sh" "$REPO" "$SERVER" 2>/dev/null || {
	echo "It seems doesn't exist. I am going to sync it"
	NEWREPO=${SECTION//.//}
	bash "$SDIR/newrepo.sh" "$SERVER" "$NEWREPO" || die "Can't create repo"

	while read -r PREFIX
	do
		BASE="${HASHFILE%/hashes/file}/$PREFIX"
		PARENT="${REPO#/}"
		PARENT="${PARENT%/}/"
		:> "$MANIF"
		fgrep -f- "$HASHFILE" < <(
			echo "######################################################################################"
			bash "$SDIR/sync-repos.sh" --backupurl="$BACKUPURL" --rvid="$RVID" --snap="@current" "$REPO" |
			fgrep '"send' |
			awk -F'|' '$2 ~ /.f/ {print $3}' |
			sed "s#^$PARENT#|#"
		) > "$MANIF"
		echo "Send Manifest for $(wc -l "$MANIF") of $(wc -l "$HASHFILE")"
		bash "$SDIR/send-manifest.sh" --backupurl="$BACKUPURL" --rvid="$RVID" --prefix="$PREFIX" "$MANIF" || die "Can't send manifest"
		echo "Send Seed for $(wc -l "$MANIF") of $(wc -l "$HASHFILE")"
		bash "$SDIR/send-seed.sh" --backupurl="$BACKUPURL" --rvid="$RVID" --prefix="$PREFIX" --base="$BASE" "$MANIF" || die "Can't send seed"
	done < <(cut -d'|' -f4 "$HASHFILE"|cut -d'/' -f1 |sed /^$/d |sort -u)
	echo -e "\n####################################Clean####################################"
	bash "$SDIR/clean.sh" --backupurl="$BACKUPURL" --rvid="$RVID" "$REPO" || die "Can't clean"
	echo -e "\n####################################Update dirs##############################"
	bash "$SDIR/update-dirs.sh" --backupurl="$BACKUPURL" --rvid="$RVID" "$REPO" || die "Can't update dirs"
	echo -e "\n####################################Check before Snap########################"
	bash "$SDIR/chk-current.sh" --backupurl="$BACKUPURL" --rvid="$RVID" --snap="@current" "$REPO"|fgrep -v '/hashes/file|'
	echo -e "\n####################################Snap#####################################"
	bash "$SDIR/snap-now.sh" --backupurl="$BACKUPURL" --rvid="$RVID" "$REPO" || die "Can't snap"
	echo Replication done
}
echo "Done compare $REPO on server $SERVER"
