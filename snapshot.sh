#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR
OS=$(uname -o |tr '[:upper:]' '[:lower:]')

die() { echo -e "$@">&2; exit 1; }
exists() { type "$1" >/dev/null 2>&1;}
getdev(){
    DEV=$(bash "$SDIR/getdev.sh" "$1") || die "Volume $1 not found"
    MOUNT=$(df --output=target "$DEV"|tail -n 1)
    [[ -z $MOUNT && $UID -eq 0  && -b $DEV ]] && { #if it is a block device, then check if it is mounted and mount it if not
        MOUNT=/tmp/bkit-$(date +%s) && mkdir -pv $MOUNT && {
            mount -o ro $DEV  $MOUNT || die Cannot mount $DEV on $MOUNT
            trap "umount $DEV && rm -rvf $MOUNT" EXIT
        }
    }
    [[ -e $MOUNT ]] || die "Disk $DEV is not mounted"
    MOUNT=${MOUNT%%/} #remove trailing slash if any
}
redirectlogs() {
    local LOGDIR=$1
    [[ -d $LOGDIR ]] || mkdir -pv "$LOGDIR"
    local STARTDATE=$(date +%Y-%m-%dT%H-%M-%S)
    LOGFILE="$LOGDIR/log-$STARTDATE"
    ERRFILE="$LOGDIR/err-$STARTDATE"
    :> $LOGFILE
    :> $ERRFILE
    echo "Logs go to $LOGFILE"
    echo "Errors go to $ERRFILE"
    exec 1>"$LOGFILE"
    exec 2>"$ERRFILE"
}
RSYNCOPTIONS=()
OPTIONS=()
while [[ $1 =~ ^- ]]
do
    KEY="$1" && shift
    case "$KEY" in
        -l|-log|--log)
            exec 1>"$1"
            shift
        ;;
        --logdir)
            redirectlogs $1 && shift
        ;;
        --logdir=*)
            redirectlogs "${KEY#*=}"
        ;;
        -u|--uuid)
            getdev "$1" && shift
        ;;
        -u=*|--uuid=*)
            getdev "${KEY#*=}"
        ;;
        -- )
            while [[ $1 =~ ^- ]]
            do
                RSYNCOPTIONS+=("$1")
                shift
            done
        ;;
        --stats|--sendlogs|--notify)
            OPTIONS+=( "$KEY")
        ;;
        *=*)
            OPTIONS+=( "$KEY")
        ;;
        *)
            OPTIONS+=( "$KEY" "$1" ) && shift
        ;;
    esac
done

DIRS=("$@")

declare -A ROOTS
declare -A ROOTOF

for DIR in "${DIRS[@]}"
do
    DIR=${DIR#/} # remove leading slash if any
    [[ -n ${MOUNT+isset} ]] && FULL=$MOUNT/$DIR || FULL=$DIR
    FULL=$(readlink -ne "$FULL") || continue
    exists cygpath && FULL=$(cygpath -u "$FULL")
    ROOT=$(stat -c%m "$FULL")
    ROOTS["$ROOT"]=1
    ROOTOF["$FULL"]=$ROOT
done

backup() {
    echo Backup directly -- without shadow copy
    bash "$SDIR/backup.sh" "${OPTIONS[@]}" -- "${RSYNCOPTIONS[@]}" "$@"
}

ntfssnap(){
    echo Backup a ntfs shadow copy
    SHADOWSPAN=$(find "$SDIR/3rd-party" -type f -iname 'ShadowSpawn.exe' -print -quit)
    for I in "${!RSYNCOPTIONS[@]}"
    do
        [[ ${RSYNCOPTIONS[$I]} =~ --filter=\.[[:space:]]+ ]] && {
            FILE=${RSYNCOPTIONS[$I]#--filter=\.}
            FILE=${FILE#${FILE%%[![:space:]]*}}  #remoce leading spaces
            EXT=${FILE##*.}
            NEWFILE=${FILE%.$EXT}-$$.$EXT
            OLDROOT=$(cygpath -u "$1")
            NEWROOT=$(cygpath -u "$2")
            OLDROOT=${OLDROOT%/}
            NEWROOT=${NEWROOT%/}
            cat "$FILE" |sed -E "s#([+-]/\s+)$OLDROOT#\\1$NEWROOT#" > "$NEWFILE"
            RSYNCOPTIONS[$I]=${RSYNCOPTIONS[$I]/$FILE/$NEWFILE}
            RMFILES+=( "$NEWFILE" )
        }
    done
    "$SHADOWSPAN" /verbosity=2 "$1" "$2" "$DOSBASH" "$SDIR/backup.sh" "${OPTIONS[@]}" --map "$2" -- "${RSYNCOPTIONS[@]}" "${@:3}"
}

RMFILES=()
trap '
    rm -f "${RMFILES[@]}"
    [[ -s $ERRFILE ]] || rm -f "$ERRFILE"
' EXIT

for ROOT in ${!ROOTS[@]}
do
    BACKUPDIR=()
    for DIR in "${!ROOTOF[@]}"
    do
        [[ $ROOT == ${ROOTOF[$DIR]} ]] && BACKUPDIR+=( "$DIR" )
    done
    [[ ${#BACKUPDIR[@]} -gt 0 ]] || continue

    [[ $OS == cygwin ]] && (id -G|grep -qE '\b544\b') && {
        DRIVE=$(cygpath -w "$(stat -c%m "$ROOT")")

        DOSBASH=$(cygpath -w "$BASH")

        NTFS=$(FSUTIL FSINFO VOLUMEINFO $DRIVE | fgrep -i "File System Name" | fgrep -oi "NTFS")
        FIXED=$(FSUTIL FSINFO DRIVETYPE $DRIVE | fgrep -oi "Fixed Drive")
        CDRIVES=$(FSUTIL FSINFO DRIVES|sed 'N;s/\n//g;/^$/d'|tr '\0' ' '|grep -Poi '(?<=Drives:\s).*'|tr '[:lower:]' '[:upper:]')

        for LETTER in {H..Z} B {D..G} A
        do
        	[[ $CDRIVES =~ $LETTER ]] || {
        		MAPLETTER="${LETTER}:" && break
        	}
        done

        if [[ -n $MAPLETTER && -n $FIXED && -n $NTFS ]]
        then
            ntfssnap $DRIVE $MAPLETTER "${BACKUPDIR[@]}"
        else
            backup "${BACKUPDIR[@]}"
        fi
    } || {
        backup "${BACKUPDIR[@]}"
    }
done


