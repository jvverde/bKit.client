#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR
OS=$(uname -o |tr '[:upper:]' '[:lower:]')

source "$SDIR/functions/all.sh"

MOUNTED=()
getdev(){
    DEV=$(bash "$SDIR/getdev.sh" "$1") || die "Device $1 not found"
    DEV=$(readlink -e "$DEV") || die "Device $1 doesn't exists"
    MOUNT=$(df --output=target "$DEV"|tail -n 1)
    [[ -z $MOUNT && $UID -eq 0  && -b $DEV ]] && { #if it is a block device, then check if it is mounted and mount it if not
        MOUNT=/tmp/bkit-$(date +%s) && mkdir -pv $MOUNT && {
            mount -o ro $DEV  $MOUNT || die Cannot mount $DEV on $MOUNT
            MOUNTED+=( "$MOUNT" )
        }
    }
    [[ -e $MOUNT ]] || die "Disk $DEV is not mounted"
    MOUNT=${MOUNT%/} #remove trailing slash if any
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
        -l=*|-log=*|--log=*)
            exec 1>"${KEY#*=}"
        ;;
        --logdir)
            redirectlogs $1 snapshot && shift
        ;;
        --logdir=*)
            redirectlogs "${KEY#*=}" snapshot
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
                RSYNCOPTIONS+=( "$1" )
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
    [[ -n ${MOUNT+isset} ]] && FULL=$MOUNT/${DIR#/} || FULL="$DIR"
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
    local SHADOWSPAN=$(find "$SDIR/3rd-party" -type f -iname 'ShadowSpawn.exe' -print -quit)
    for I in "${!RSYNCOPTIONS[@]}"
    do
        [[ ${RSYNCOPTIONS[$I]} =~ --filter=\.[[:space:]]+ ]] && { # map rules from original root to mapped root
            local FILE="$(echo ${RSYNCOPTIONS[$I]} | cut -d' ' -f2-)"
            local NEWFILE="$RUNDIR/rule-$$.$I"
            local OLDROOT=$(cygpath -u "$1")
            local NEWROOT=$(cygpath -u "$2")
            OLDROOT=${OLDROOT%/}
            NEWROOT=${NEWROOT%/}
            cat "$FILE" |sed -E "s#([+-]/?\s+)$OLDROOT#\\1$NEWROOT#" > "$NEWFILE"
            RSYNCOPTIONS[$I]=${RSYNCOPTIONS[$I]/$FILE/$NEWFILE} #replace original rule file by a temporary rule file
            RMFILES+=( "$NEWFILE" ) #include temporary rule in a list of files to remove at the end.
        }
    done
    "$SHADOWSPAN" /verbosity=2 "$1" "$2" "$DOSBASH" "$SDIR/backup.sh" "${OPTIONS[@]}" --map "$2" -- "${RSYNCOPTIONS[@]}" "${@:3}"
}

RUNDIR="$SDIR/run"
RMFILES=()
trap '
    rm -f "${RMFILES[@]}"
    [[ -s $ERRFILE ]] || rm -f "$ERRFILE"
    for M in ${MOUNTED[@]}
    do 
      umount "$M" && rmdir "$M"
    done
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


