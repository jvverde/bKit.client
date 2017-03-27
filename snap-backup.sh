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
            BASEDIR=$(bash "$SDIR/getdev.sh" "$1")
            shift
        ;;
        -d|--dir)
            STARTDIR="$1" && shift
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

[[ -e $1 ]] || die "'$1' was does not not exists"
DIR=$1
exists cygpath && DIR=$(cygpath "$DIR")
DIR=$(readlink -e "$1")

[[ $OS == cygwin ]] && (id -G|grep -qE '\b544\b') && {
    DRIVE=$(cygpath -w "$(stat -c%m "$DIR")")

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
    	echo Backup shadow copy
    	SHADOWSPAN=$(find "$SDIR/3rd-party" -type f -iname 'ShadowSpawn.exe' -print -quit)
    	"$SHADOWSPAN" /verbosity=2 $DRIVE $MAPLETTER "$DOSBASH" "$SDIR/backup.sh" -- "${RSYNCOPTIONS[@]}" "$DIR" $MAPLETTER
    else
    	echo Backup directly -- without shadow copy
    	bash "$SDIR%backup.sh" -- "${RSYNCOPTIONS[@]}" "$DIR"
    fi
} || {
    bash "$SDIR/backup.sh" -- "${RSYNCOPTIONS[@]}" "$DIR"
}
