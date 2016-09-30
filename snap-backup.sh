#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR
die() { echo -e "$@">&2; exit 1; }

[[ $1 =~ ^-{1,2}l(og)? ]] && shift && exec 1>"$1" && shift  #-l|-log|--log option

[[ -e $1 ]] || die "'$1' was does not not exists"

DIR=$(cygpath -u "$(readlink -e "$1")")
DRIVE=$(cygpath -w "$(stat -c%m "$DIR")")

DOSBASH=$(cygpath -w "$BASH")

NTFS=$(FSUTIL FSINFO VOLUMEINFO $DRIVE | fgrep -i "File System Name" | fgrep -oi "NTFS")
FIXED=$(FSUTIL FSINFO DRIVETYPE $DRIVE | fgrep -oi "Fixed Drive")
CDRIVES=$(FSUTIL FSINFO DRIVES|sed 's/\r//g;/^$/d'|tr '\0' ' '|grep -Poi '(?<=Drives:\s).*'|tr '[:lower:]' '[:upper:]')

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
	"$SHADOWSPAN" /verbosity=4 $DRIVE $MAPLETTER "$DOSBASH" "'$SDIR/backup.sh'" "'$DIR'" $MAPLETTER
else
	echo Backup directly -- without shadow copy
	bash "%SDIR%backup.sh" "$DIR"
fi
