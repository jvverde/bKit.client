#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH

exists() { type "$1" >/dev/null 2>&1;}
die() { echo -e "$@">&2; exit 1; }
warn() { echo -e "$@">&2; }

SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR
OS=$(uname -o |tr '[:upper:]' '[:lower:]')
RSYNCOPTIONS=()

while [[ $1 =~ ^- ]]
do
	KEY="$1" && shift
	case "$KEY" in
		-l|-log|--log)
			exec 1>"$1"
			shift
		;;
		-f|--force)
			FSW='-f' #check if we need it
		;;
		-m|--map)
			MAPDRIVE="$1" && shift
			exists cygpath && MAPDRIVE=$(cygpath "$MAPDRIVE")
		;;
    --stats)
      STATS=1
    ;;
    --sendlogs)
      FULLREPORT=1
      NOTIFY=1
      STATS=1
    ;;
    --notify)
      NOTIFY=1
      STATS=1
    ;;
    --email=*)
      EMAIL="${KEY#*=}"
      NOTIFY=1
      STATS=1
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

BASEDIR=("$@")

ORIGINALDIR=( "${BASEDIR[@]}" )

OLDIFS=$IFS
IFS="
"
exists cygpath && BASEDIR=( $(cygpath -u "${ORIGINALDIR[@]}") ) && ORIGINALDIR=( $(cygpath -w "${BASEDIR[@]}") )

BASEDIR=( $(readlink -e "${BASEDIR[@]}") )

ROOTS=( $(stat -c%m "${BASEDIR[@]}") )
ROOT=${ROOTS[0]}

[[ -e "$ROOT" ]] || die "I didn't find a disk for directory/file: '${BASEDIR[0]}'"

[[ -n $MAPDRIVE ]] || MAPDRIVE=$ROOT

STARTDIR=()
BACKUPDIR=()
for I in ${!ROOTS[@]}
do
	[[ "${ROOTS[$I]}" == "$ROOT" ]] || {
		warn "Roots are not in the same logical volume. These will be ignored:\n\t${ORIGINALDIR[$I]}" && continue
	}
	DIR=${BASEDIR[$I]#$ROOT}
	DIR=${DIR#/}
	STARTDIR+=( "$DIR" )
	BACKUPDIR+=( "$MAPDRIVE/$DIR" )
done

#we need ROOT, BACKUPDIR and STARTDIR
#source "$SDIR/drive.sh" "$DEV"
IFS='|' read -r VOLUMENAME VOLUMESERIALNUMBER FILESYSTEM DRIVETYPE <<<$("$SDIR/drive.sh" "$ROOT" 2>/dev/null)

IFS=$OLDIFS

[[ $DRIVETYPE =~ Ram.Disk ]] && die "These directories/files ${BACKUPDIR[@]} are in a RAM Disk"

exists cygpath && DRIVE=$(cygpath -w "$ROOT")
DRIVE=${DRIVE%%:*}

#compute Remote Volume ID
RVID="${DRIVE:-_}.${VOLUMESERIALNUMBER:-_}.${VOLUMENAME:-_}.${DRIVETYPE:-_}.${FILESYSTEM:-_}"
CONF="$SDIR/conf/conf.init"
[[ -f $CONF ]] || die Cannot found configuration file at $CONF
source "$CONF"
exists rsync || die Cannot find rsync

trap '' SIGPIPE

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

RUNDIR=$SDIR/run
[[ -d $RUNDIR ]] || mkdir -p $RUNDIR
FLIST=$RUNDIR/file-list.$$
HLIST=$RUNDIR/hl-list.$$
DLIST=$RUNDIR/dir-list.$$
MANIFEST=$RUNDIR/manifest.$$
ENDFLAG=$RUNDIR/endflag.$$
LOCK=$RUNDIR/${VOLUMESERIALNUMBER:-_}
LOGFILE=$RUNDIR/logs.$$
ERRFILE=$RUNDIR/errors.$$
STATSFILE=$RUNDIR/stats.$$

exec 3>&2
exec 2>"$ERRFILE"

trap "
  cat \"$ERRFILE\" >&3
  rm -f $RUNDIR/*.$$ $RUNDIR/*.$$.* $LOCK
" EXIT

set_postpone_files(){
	exec 99>"$HLIST"
	exec 98>"$DLIST"
	exec 97>"$FLIST"
}
remove_postpone_files(){
	rm -f "$HLIST" "$DLIST" "$FLIST"
}
postpone_file(){
	(IFS=$'\n' && echo "$*" ) >&97
}
postpone_hl(){
	(IFS=$'\n' && echo "$*" ) >&99
}
postpone_update(){
	(IFS=$'\n' && echo "$*" ) >&98
}

FMT='--out-format="%o|%i|%f|%c|%b|%l|%t"'
PERM=(--perms --acls --owner --group --super --numeric-ids)
CLEAN=(--delete --force --delete-excluded --ignore-non-existing --ignore-existing)
FMT_QUERY='--out-format=%i|%n|%L|/%f|%l'

export RSYNC_PASSWORD="$(cat "$SDIR/conf/pass.txt")"

getacls(){
	FILE="$1"
	[[ $OS == 'cygwin' && $FILESYSTEM == 'NTFS' ]] && (id -G|grep -qE '\b544\b') && (
		METADATADIR=$SDIR/cache/metadata/by-volume/${VOLUMESERIALNUMBER:-_}
		DIRS=()
		while read DIR
		do
			DIRS+=( "$MAPDRIVE/$DIR" )
		done < "$FILE"
		bash "$SDIR/diracls.sh" "${DIRS[@]}" "$METADATADIR" |  xargs -d '\n' -I{} echo {}
		dorsync -aizR --inplace "${PERM[@]}" "$FMT" "$METADATADIR/./" "$BACKUPURL/$RVID/@current/metadata/"
	)
}

update_hardlinks(){
	FILE="${HLIST}.sort"
	LC_ALL=C sort -o "$FILE" "$HLIST"
	dorsync --archive --hard-links --relative --files-from="$FILE" --recursive --itemize-changes "${PERM[@]}" $FMT "$@"
	rm -f "$FILE"
}
update_dirs(){
	FILE="${DLIST}.sort"
	LC_ALL=C sort -o "$FILE" "$DLIST"
	dorsync --archive --relative --files-from="$FILE" --itemize-changes "${PERM[@]}" $FMT "$@"
	#getacls "$FILE"
	rm -f "$FILE"
}
update_file(){
	dorsync -tiz --inplace "${PERM[@]}" $FMT "$@"
}
update_files(){
	SRC=$1 && shift
	FILE="${SRC}.sort"
	LC_ALL=C sort -o "$FILE" "$SRC"
	dorsync --archive --inplace --hard-links --relative --files-from="$FILE" --itemize-changes "${PERM[@]}" $FMT "$@"
	rm -f "$FILE"
}

backup(){
	local BASE=$1 && shift
	#local SRC="$1/./$2"
	local SRCS=()
	for DIR in "${@:1:$#-1}"
	do
		SRCS+=( "$BASE/./$DIR" )
	done
	local DST="${@: -1}" #last argument
	unset HLINK
	set_postpone_files
	while IFS='|' read -r I FILE LINK FULLPATH LEN
	do
		echo miss "$I|$FILE|$LINK|$LEN"

		FILE=${FILE%/}	#remove trailing backslash in order to avoid sync files in a directory directly

		#if it is a directory, symlink, device or special
		[[ $I =~ ^[c.][dLDS] && "$FILE" != '.' ]] && postpone_update "$FILE" && continue

		#this is the main (and most costly) case. A file, or part of it, need to be transfer
		[[ $I =~ ^[.\<]f ]] && (
			HASH=$(sha256sum -b "$FULLPATH" | cut -d' ' -f1)
			PREFIX=$(echo $HASH|sed -E 's#^(.)(.)(.)(.)(.)(.)#\1/\2/\3/\4/\5/\6/#')
			[[ $PREFIX =~ ././././././ ]] || { echo "Prefix $PREFIX !~ ././././././" && exit;}
			#echo "$PREFIX|$(stat -c '%s|%Y' "$FULLPATH")|$FILE"
			echo "$PREFIX|$(stat -c '%s|%Y' "$FULLPATH")|$FILE" >> "$MANIFEST"
		) && continue

		#if a hard link (to file or to symlink)
		[[ $I =~ ^h[fL] && $LINK =~ =\> ]] && LINK=$(echo $LINK|sed -E 's/\s*=>\s*//') &&  postpone_hl "$LINK" "$FILE" && continue

		#there are situations where the rsync don't know yet the target of a hardlink, so we need to flag this situation and later we take care of it
		[[ $I =~ ^h[fL] && ! $LINK =~ =\> ]] && HLINK=missing && continue

		echo "Is something else:$I|$FILE|$LINK|$LEN"

	done < <(dorsync --dry-run --no-verbose --archive --hard-links --relative --itemize-changes "${PERM[@]}" $FMT_QUERY "${SRCS[@]}" "$DST")
	update_dirs	"$BASE" "$DST"
	update_hardlinks "$BASE" "$DST"
	remove_postpone_files
}
clean(){
	local BASE=$1 && shift
	#local SRC="$1/./$2"
	local SRCS=()
	for DIR in "${@:1:$#-1}"
	do
		SRCS+=( "$BASE/./$DIR" )
	done
	local DST="${@: -1}" #last argument

	dorsync -riHDR "${CLEAN[@]}" "${PERM[@]}" $FMT "${SRCS[@]}" "$DST" #clean deleted files
}
snapshot(){
	dorsync --dry-run --dirs --ignore-non-existing --ignore-existing "$MAPDRIVE/./" "$BACKUPURL/$RVID/@snap"
}
prepare(){
	dorsync --dry-run --dirs --ignore-non-existing --ignore-existing "$MAPDRIVE/./" "$BACKUPURL/$RVID/@current/data"
}
wait4jobs(){
	while list=($(jobs -rp)) && ((${#list[*]} > 0))
	do
		#10.11.echo Wait for ${#list[*]} job to finish
		wait -n
	done
}

bg_upload_manifest(){
	local BASE="$1"
	[[ -e $MANIFEST ]] || touch "$MANIFEST"
	[[ -e $ENDFLAG ]] && rm -f "$ENDFLAG"

	(	#start a subshell to run in background
		let START=1
		let LEN=500
		SEGMENT=$RUNDIR/manifest-segment.$$
		SEGFILES=$RUNDIR/segment-files.$$
		while [[ -e $MANIFEST ]]
		do
			let END=LEN+START-1
			let CNT=$(sed -n "${START},${END}p;${END}q" "$MANIFEST"|tee "$SEGMENT" |wc -l)
			(( CNT == 0 )) && [[ -e $ENDFLAG ]] && break
			(( CNT == 0 )) && sleep 1 && continue
			(( CNT < LEN )) && sed -ni "1,${CNT}p" "$SEGMENT" 								#avoid send incomplete lines
			update_file "$SEGMENT" "$BACKUPURL/$RVID/@manifest/data/manifest.lst"
			update_file "$SEGMENT" "$BACKUPURL/$RVID/@apply-manifest/data/manifest.lst"
			cut -d'|' -f4- "$SEGMENT" > "$SEGFILES"
			update_files "$SEGFILES" "$BASE" "$BACKUPURL/$RVID/@seed/data"
			update_file "$SEGMENT" "$BACKUPURL/$RVID/@apply-seed/data/manifest.lst"
			echo sent $CNT lines of manifest starting at $START
			let START+=CNT
		done
		rm -f "$SEGMENT" "$SEGFILES"
	)&
}

#(
#	flock -w $((3600*24)) 9 || {
#		rm -fv "$LOCK"
#		die Volume $VOLUMESERIALNUMBER was locked for 1 day
#	}

	ITIME=$(date -R)

	{
		prepare

		bg_upload_manifest "$MAPDRIVE"
		echo Start to backup directories/files on ${ORIGINALDIR[@]} on $ITIME

		echo -e "\nPhase 1 - Backup new/modified files\n"

		bash "$SDIR/hash.sh" --rvid="$RVID" -- "${RSYNCOPTIONS[@]}" "${BACKUPDIR[@]}" | sed -E 's#^(.)(.)(.)(.)(.)(.)#\1/\2/\3/\4/\5/\6/#' > "$MANIFEST"

		touch "$ENDFLAG"
		wait4jobs
		rm -f "$MANIFEST" "$ENDFLAG"

		echo -e "\nPhase 2 - Update Symbolic links, Hard links, Directories and file attributes\n"

		bg_upload_manifest "$MAPDRIVE"

		backup "$MAPDRIVE" "${STARTDIR[@]}" "$BACKUPURL/$RVID/@current/data"

		[[ -n $HLINK ]] && {
			echo -e "\n\tPhase 2.1 update delayed hardlinks"
			backup "$MAPDRIVE" "${STARTDIR[@]}" "$BACKUPURL/$RVID/@current/data"
		}

		touch "$ENDFLAG"
		wait4jobs
		rm -f "$MANIFEST" "$ENDFLAG"


		echo -e "\nPhase 3 - Clean deleted files from backup\n"

		clean "$MAPDRIVE" "${STARTDIR[@]}" "$BACKUPURL/$RVID/@current/data"

		echo -e "\nPhase 4 - Create a readonly snapshot on server\n"
		
    snapshot

		echo "Backup done on $(date -R) for:"
		for I in ${!ORIGINALDIR[@]}
		do
			echo "Files/directories '${ORIGINALDIR[$I]}' backed up on:"
			echo -e "\t$BACKUPURL/$RVID/@current/data/${STARTDIR[$I]}"
		done
	} | tee "$LOGFILE"

	#Now some stats
	deltatime(){
		let DTIME=$(date +%s -d "$1")-$(date +%s -d "$2")
		SEC=${DTIME}s
		(($DTIME>59)) && {
			let SEC=DTIME%60
			let DTIME=DTIME/60
			SEC=${SEC}s
			MIN=${DTIME}m
			(($DTIME>59)) && {
				let MIN=DTIME%60
				let DTIME=DTIME/60
				MIN=${MIN}m
				HOUR=${DTIME}h
				(($DTIME>23)) && {
					let HOUR=DTIME%24
					let DTIME=DTIME/24
					DAYS=${DTIME}d
				}
			}
		}
		DELTATIME="$DAYS$HOUR$MIN$SEC"
	}
	[[ -n $STATS && -e $LOGFILE && -e "$SDIR/tools/stats.pl" ]] && exists perl && {
    echo "------------Stats------------"
    deltatime "$(date -R)" "$ITIME"
		echo "Total time spent: $DELTATIME"
    exists cygpath && ROOT=$(cygpath -w "$ROOT")
    grep -Pio '^".+"$' "$LOGFILE" | awk -vA="$ROOT" 'BEGIN {FS = OFS = "|"} {print $1,$2,A $3,$4,$5,$6,$7}' | perl "$SDIR/tools/stats.pl"
    echo "------------End of Stats------------"
  } | tee "$STATSFILE"

  #Sent email if required
  [[ -n $NOTIFY && -s $STATSFILE ]] && (
    SMTP="$SDIR/conf/smtp.conf"
    [[ -f $SMTP ]] || die "Email not sent because configuration file '$SMTP' is missing"
    ME=$(uname -n)
    TIME=$(date +%Hh%Mm)
    FULLDIRS=( $(readlink -e "${ORIGINALDIR[@]}") )     #get full paths
    exists cygpath &&  FULLDIRS=( $(cygpath -w "${FULLDIRS[@]}") )
    printf -v DIRS "%s, " "${FULLDIRS[@]}"
    DIRS=${DIRS%, }
    WHAT=$DIRS
    let NUMBEROFDIRS=${#FULLDIRS[@]}
    let LIMIT=3
    let EXTRADIRS=NUMBEROFDIRS-LIMIT
    ((NUMBEROFDIRS > LIMIT)) && WHAT="${FULLDIRS[0]} and $EXTRADIRS more directories/files"
    STATUS="success"
    [[ -s $ERRFILE ]] && STATUS="errors"
    SUBJECT="Backup of $WHAT on $ME ended at $TIME with $STATUS"
    source "$SMTP"
    DEST=${EMAIL:-$TO}
    [[ -n $DEST ]] || die "Email destination not defined"
    {
      echo "Backup of $DIRS"
      cat "$STATSFILE"

      [[ -s $ERRFILE ]] && {
        echo -e "\n------------Errors found------------"
        cat "$ERRFILE"
        echo "------------End of Errors------------"
      }

      [[ -n $FULLREPORT ]] && {
        echo -e "\n------------Full Logs------------"
        cat "$LOGFILE"
        echo "------------End of Logs------------"
      }
    } | (
      exists email && email -smtp-server $SERVER -subject "$SUBJECT" -from-name "$ME" -from-addr "backup-${ME}@bkit.pt" "$DEST" && exit
      exists mail && mail -s "$ME" "$DEST" && exit
    )
  )
	deltatime "$(date -R)" "$ITIME"
	echo "Backup done in $DELTATIME"
#) 9>"$LOCK"

