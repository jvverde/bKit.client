#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR
[[ $1 == '-log' ]] && shift && exec 1>"$1" && shift

exists() { type "$1" >/dev/null 2>&1;}
die() { echo -e "$@">&2; exit 1; }


UUID=$1
[[ -n $UUID ]] || die "Usage:\n\t$0 UUID"
exists lsblk && {
	[[ $UID -eq 0 ]] || exec sudo "$0" "$@"
	NAME=$(lsblk -lno KNAME,UUID|grep -i "\b$UUID\b"|head -n 1|cut -d' ' -f1)
	DEV=${NAME:+/dev/$NAME}
	[[ -e $DEV ]] || die "'$DEV' does not exists"
	echo "$DEV"
}
exists fsutil &&{
	DRIVE=($(fsutil fsinfo drives|sed /^$/d|grep -io '[a-z]:\\'|xargs -d'\n' -rI{} sh -c '
		fsutil fsinfo volumeInfo "$1"|grep -iq "\bVolume Serial Number\s*:\s*0x$2\b" && echo $1 && exit
	' -- {} "$UUID"))
	[[ -e $DRIVE ]] || die "'$DRIVE' does not exits"
	echo "$DRIVE"
}
