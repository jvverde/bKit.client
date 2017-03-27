#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR
OS=$(uname -o |tr '[:upper:]' '[:lower:]')

die() { echo -e "$@">&2; exit 1; }
exists() { type "$1" >/dev/null 2>&1;}


RSYNCOPTIONS=()

while [[ $1 =~ ^- ]]
do
    KEY="$1" && shift
    case "$KEY" in
        -l|-log|--log)
            exec 1>"$1"
            shift
        ;;
        -u|--uuid)
            DIR=$(bash "$SDIR/getdev.sh" "$1") || die "Volume $1 not found"
            shift
        ;;
        -d|--dir)
            STARTDIR="$1" && shift
            exists cygpath && STARTDIR=$(cygpath "$STARTDIR")
            BASE=$(stat -c%m "$STARTDIR" 2>/dev/null) && STARTDIR=${STARTDIR#$BASE}
        ;;
        -- )
            while [[ $1 =~ ^- ]]
            do
                RSYNCOPTIONS+=("$1")
                shift
            done
        ;;
        *)
            die Unknow  option $KEY
        ;;
    esac
done

true ${DIR:=$1}
exists cygpath && DIR=$(cygpath "$DIR")

DIR=$(readlink -ne "$DIR") || die "Directory doesn't exists"

[[ -b $DIR ]] && { #if it is a block device, then check if it is mounted and mount it if not
    DEV=$DIR
    MOUNT=$(df --output=target $DEV|tail -n 1)
    [[ -z $MOUNT && $UID -eq 0 ]] && MOUNT=/tmp/bkit-$(date +%s) && mkdir -pv $MOUNT && {
        mount -o ro $DEV  $MOUNT || die Cannot mount $DEV on $MOUNT
        trap "umount $DEV && rm -rvf $MOUNT" EXIT
    }
} || { #otherwise extract ROOT and STARTDIR
    MOUNT=$(stat -c%m "$DIR")
}
true ${STARTDIR:=${DIR#$MOUNT}}
STARTDIR=${STARTDIR#/}

BACKUPDIR=$MOUNT/$STARTDIR

[[ -e $BACKUPDIR ]] || die "$BACKUPDIR doesn't exists"

backup() {
    echo Backup directly -- without shadow copy
    bash "$SDIR/backup.sh" -- "${RSYNCOPTIONS[@]}" "$BACKUPDIR"
}

ntfssnap(){
    echo Backup a ntfs shadow copy
    SHADOWSPAN=$(find "$SDIR/3rd-party" -type f -iname 'ShadowSpawn.exe' -print -quit)
    "$SHADOWSPAN" /verbosity=2 "$1" "$2" "$DOSBASH" "$SDIR/backup.sh" --map "$2" -- "${RSYNCOPTIONS[@]}" "$BACKUPDIR"
}

[[ $OS == cygwin ]] && (id -G|grep -qE '\b544\b') && {
    DRIVE=$(cygpath -w "$(stat -c%m "$BACKUPDIR")")

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
        ntfssnap $DRIVE $MAPLETTER
    else
        backup
    fi
} || {
    backup
}
