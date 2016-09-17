#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR
[[ $1 == '-log' ]] && shift && exec 1>"$1" && shift

exists() { type "$1" >/dev/null 2>&1;}
die() { echo -e "$@">&2; exit 1; }


UUID=$1
[[ -n $UUID ]] || die "Usage:\n\t$0 UUID"
set -o pipefail
exists lsblk && {
	NAME=$(lsblk -lno NAME,UUID|grep -i "\b$UUID\b"|cut -d' ' -f1) || die Device not found
	DEV=${NAME:+/dev/$NAME}
	[[ -e $DEV ]] || die "'$DEV' does not exists"
	echo "$DEV"
}
exists fsutil &&{
	DRIVE=($(fsutil fsinfo drives|sed /^$/d|grep -io '[a-z]:\\'|xargs -d'\n' -rI{} sh -c '
		fsutil fsinfo volumeInfo "$1"|grep -iq "Volume Serial Number\s*:\s*0x$2" && echo $1
	' -- {} "$UUID"))
	[[ -e $DRIVE ]] || die "'$DRIVE' does not exits"
	echo "$DRIVE"
}
