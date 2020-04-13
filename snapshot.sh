#!/usr/bin/env bash
#Backup shadow copies if it is a NTFS and a Fixed Disk. And user have admin rights (544 output from id -G) 
#In case of shodow copies it also rewrite path locatiosn for possible filter rsync options
#In all other situation just call backup.sh

declare sdir="$(dirname -- "$(readlink -ne -- "$0")")"				#Full DIR

source "$sdir/lib/functions/all.sh"


MOUNTED=()
getdev(){
    DEV=$("$sdir/lib/getdev.sh" "$1"|head -n1|perl -lape 's/(?:\r|\n)+$//g') || die "Device $1 not found"
	exists cygpath && DEV="$(cygpath -u "$DEV")"
    DEV=$(readlink -e "$DEV") || die "Device '$DEV' doesn't exists"
    MOUNT=$(df --output=target,fstype "$DEV"|tail -n 1|fgrep -v devtmpfs|cut -f1 -d' ')
    [[ -z $MOUNT && $UID -eq 0  && -b $DEV ]] && { #if it is a block device, then check if it is mounted and mount it if not
	mktempdir MOUNT || die "can't make temporary directory '$MOUNT'"
        mount -o ro $DEV  $MOUNT || die Cannot mount $DEV on $MOUNT
        MOUNTED+=( "$MOUNT" )
    }
    [[ -e $MOUNT ]] || die "Disk $DEV is not mounted"
    MOUNT=${MOUNT%/} #remove trailing slash if any
}

#echo args="${@}"
declare -a rsyncoptions=()
declare -a options=()
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
            redirectlogs $1 snapshot && shift			#redirectlogs is defined on util.sh
        ;;
        --logdir=*)
            redirectlogs "${KEY#*=}" snapshot			#redirect to argument given and prefix the log files with 'snapshot' string
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
                rsyncoptions+=( "$1" )
                shift
            done
        ;;
        --stats|--sendlogs|--notify)
            options+=( "$KEY")
        ;;
        *=*)
            options+=( "$KEY")
        ;;
        *)
            options+=( "$KEY" "$1" ) && shift
        ;;
    esac
done

DIRS=("$@")

declare -A ROOTS
declare -A ROOTOF

for DIR in "${DIRS[@]}"
do
    [[ ${MOUNT+isset} == isset ]] && FULL=$MOUNT/${DIR#/} || FULL="$DIR"
    FULL=$(readlink -ne "$FULL") || continue
    exists cygpath && FULL=$(cygpath -u "$FULL")
    ROOT=$(stat -c%m "$FULL")
    ROOTS["$ROOT"]=1
    ROOTOF["$FULL"]=$ROOT
done

backup() {
    echo Backup directly -- without shadow copy
    bash "$sdir/backup.sh" ${options[@]+"${options[@]}"} -- ${rsyncoptions[@]+"${rsyncoptions[@]}"} "$@"
}

ntfssnap(){
    echo Backup a ntfs shadow copy
    local SHADOWSPAN=$(find "$sdir/3rd-party" -type f -iname 'ShadowSpawn.exe' -print -quit)
    for I in "${!rsyncoptions[@]}"
    do
        [[ ${rsyncoptions[$I]} =~ --filter=\.[[:space:]]+ ]] && { # map rules from original root to mapped root
            local FILE="$(echo ${rsyncoptions[$I]} | cut -d' ' -f2-)"
            local NEWFILE="$RUNDIR/rule-$$.$I"
            local OLDROOT=$(cygpath -u "$1")
            local NEWROOT=$(cygpath -u "$2")
            OLDROOT=${OLDROOT%/}
            NEWROOT=${NEWROOT%/}
            cat "$FILE" |sed -E "s#([+-]/?\s+)$OLDROOT#\\1$NEWROOT#" > "$NEWFILE"
            rsyncoptions[$I]=${rsyncoptions[$I]/$FILE/$NEWFILE} #replace original rule file by a temporary rule file
            RMFILES+=( "$NEWFILE" ) #include temporary rule in a list of files to remove at the end.
        }
    done
    "$SHADOWSPAN" /verbosity=2 "$1" "$2" "$DOSBASH" "$sdir/backup.sh" ${options[@]+"${options[@]}"} --map "$2" -- ${rsyncoptions[@]+"${rsyncoptions[@]}"} "${@:3}"
 }

mktempdir RUNDIR
RMFILES=()

finish(){
    rm -f "${RMFILES[@]}"
    [[ -s $ERRFILE ]] || rm -f "$ERRFILE"
    for M in ${MOUNTED[@]}
    do 
      umount "$M" && rmdir "$M"
    done
}

atexit finish

for ROOT in ${!ROOTS[@]}
do
    BACKUPDIR=()
    for DIR in "${!ROOTOF[@]}"
    do
        [[ $ROOT == ${ROOTOF[$DIR]} ]] && BACKUPDIR+=( "$DIR" )
    done
    [[ ${#BACKUPDIR[@]} -gt 0 ]] || continue

	echo 
    [[ $OS == cygwin ]] && (id -G|grep -qE '\b544\b') && {
        DRIVE=$(cygpath -w "$(stat -c%m "$ROOT")")
		DRIVE2="${DRIVE%\\}"
        
		DOSBASH=$(cygpath -w "$BASH")

        NTFS=$(FSUTIL FSINFO VOLUMEINFO $DRIVE2 | fgrep -i "File System Name" | fgrep -oi "NTFS")
        FIXED=$(FSUTIL FSINFO DRIVETYPE $DRIVE2 | fgrep -oi "Fixed Drive")
        CDRIVES=$(FSUTIL FSINFO DRIVES|sed 'N;s/\n//g;/^$/d'|tr '\0' ' '|grep -Poi '(?<=Drives:\s).*'|tr '[:lower:]' '[:upper:]')

        for LETTER in {I..Z} B {D..H} A
        do
        	[[ $CDRIVES =~ $LETTER ]] || {
        		MAPLETTER="${LETTER}:" && break
        	}
        done

        if [[ -n $MAPLETTER && -n $FIXED && -n $NTFS ]]
        then
            echo ntfssnap $DRIVE $MAPLETTER "${BACKUPDIR[@]}"
            ntfssnap $DRIVE $MAPLETTER "${BACKUPDIR[@]}"
        else
            backup "${BACKUPDIR[@]}"
        fi
    } || {
        backup "${BACKUPDIR[@]}"
    }
done
