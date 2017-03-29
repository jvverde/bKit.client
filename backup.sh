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

exists cygpath && [[ -n $MAPDRIVE ]] && MAPDRIVE=$(cygpath "$MAPDRIVE") || MAPDRIVE=$ROOT

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

dorsync(){
	local RETRIES=1000
	while true
	do
		rsync "${RSYNCOPTIONS[@]}" --one-file-system --compress "$@" 2>&1
		local ret=$?
		case $ret in
			0) break 									#this is a success
			;;
			5|10|12|30|35)
				DELAY=$((1 + RANDOM % 60))
				echo Received error $ret. Try again in $DELAY seconds
				sleep $DELAY
				echo Try again now
			;;
			*)
				echo Fail to backup. Exit value of rsync is non null: $ret
				break
			;;
		esac
		(( --RETRIES < 0 )) && echo "I'm tired of trying" && break
	done
}

RUNDIR=$SDIR/run
[[ -d $RUNDIR ]] || mkdir -p $RUNDIR
FLIST=$RUNDIR/file-list.$$
HLIST=$RUNDIR/hl-list.$$
DLIST=$RUNDIR/dir-list.$$
MANIFEST=$RUNDIR/manifest.$$
ENDFLAG=$RUNDIR/endflag.$$

trap "rm -fv $RUNDIR/*.$$ $RUNDIR/*.$$.*" EXIT

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
	rm -f "$FILE"
}
update_file(){
	dorsync -tiz --inplace "${PERM[@]}" $FMT "$@"
}
update_files(){
	SRC=$1 && shift
	FILE="${SRC}.sort"
	LC_ALL=C sort -o "$FILE" "$SRC"
	dorsync --archive --inplace --hard-links --relative --files-from="$FILE" --recursive --itemize-changes "${PERM[@]}" $FMT "$@"
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
			echo "$PREFIX|$SIZE|$TIME|$FILE" >> "$MANIFEST"
		) && continue

		#if a hard link (to file or to symlink)
		[[ $I =~ ^h[fL] && $LINK =~ =\> ]] && LINK=$(echo $LINK|sed -E 's/\s*=>\s*//') &&  postpone_hl "$LINK" "$FILE" && continue

		#there are situations where the rsync don't know yet the target of a hardlink, so we need to flag this situation and later we take care of it
		[[ $I =~ ^h[fL] && ! $LINK =~ =\> ]] && HLINK=missing && continue

		echo "Is something else:$I|$FILE|$LINK|$LEN"

	done < <(dorsync --dry-run --archive --hard-links --relative --itemize-changes "${PERM[@]}" $FMT_QUERY "${SRCS[@]}" "$DST")
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
wait4jobs(){
	while list=($(jobs -rp)) && ((${#list[*]} > 0))
	do
		echo Wait for ${#list[*]} job to finish
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

LOCK=$RUNDIR/${VOLUMESERIALNUMBER:-_}

(
	flock -w $((3600*24)) 9 || {
		rm -fv "$LOCK"
		die Volume $VOLUMESERIALNUMBER was locked
	}

	bg_upload_manifest "$MAPDRIVE"

	echo Start to backup of directories/files ${ORIGINALDIR[@]} at $(date -R)

	echo Phase 1 - Backup new/modified files

	time (bash "$SDIR/hash.sh" -- "${RSYNCOPTIONS[@]}" "${BACKUPDIR[@]}" | sed -E 's#^(.)(.)(.)(.)(.)(.)#\1/\2/\3/\4/\5/\6/#' > "$MANIFEST") && echo got data hashes
	touch "$ENDFLAG"
	wait4jobs
	rm -f "$MANIFEST" "$ENDFLAG"

	echo Phase 2 - Update Symbolic links, Hard links, Directories and update file attributes

	bg_upload_manifest "$MAPDRIVE"

	time backup "$MAPDRIVE" "${STARTDIR[@]}" "$BACKUPURL/$RVID/@current/data" && echo backup data done

	[[ -n $HLINK ]] && time backup "$MAPDRIVE" "${STARTDIR[@]}" "$BACKUPURL/$RVID/@current/data"	&& echo checked missed hardlinks

	touch "$ENDFLAG"
	wait4jobs
	rm -f "$MANIFEST" "$ENDFLAG"


	time clean "$MAPDRIVE" "${STARTDIR[@]}" "$BACKUPURL/$RVID/@current/data" && echo cleaned deleted files

	[[ $OS == 'cygwin' && $FILESYSTEM == 'NTFS' && false ]] && (
		METADATADIR=$SDIR/cache/metadata/by-volume/${VOLUMESERIALNUMBER:-_}
		SRCDIR=".bkit/$STARTDIR"
		[[ -d $METADATADIR/$SRCDIR ]] || mkdir -p "$METADATADIR/$SRCDIR"
		bash "$SDIR/acls.sh" "${BACKUPDIR[@]}" "$METADATADIR/$SRCDIR" 2>&1 |  xargs -d '\n' -I{} echo Acls: {} && echo got ACLS
		cd "$METADATADIR"
		PACKDIR=".tar/$STARTDIR"
		[[ -d $PACKDIR ]] || mkdir -p "$PACKDIR"
		tar --update --file "$PACKDIR/dir.tar" "$SRCDIR"
		update_file -R "$METADATADIR/./$PACKDIR/dir.tar" "$BACKUPURL/$RVID/@current/metadata/"
	) && echo Metadata tar sent to backup

	time snapshot && echo snapshot done
	echo Backup of ${ORIGINALDIR[@]} done at $(date -R)
) 9>"$LOCK"

