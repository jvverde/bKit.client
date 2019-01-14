#!/usr/bin/env bash
SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR
[[ $1 == '-log' ]] && shift && exec 1>"$1" && shift

source "$SDIR/functions/util.sh"

UUID=$1
[[ -n $UUID ]] || die "Usage:\n\t$0 UUID"

exists wmic && {
	echo -n "$(WMIC logicaldisk WHERE "VolumeSerialNumber like '$UUID'" GET Name /format:textvaluelist| sed -nr 's/Name=(.+)/\1/p')" && exit
}

exists fsutil &&{
	DRIVE=($(FSUTIL FSINFO DRIVES|sed 's/\r//g;/^$/d'|tr '\0' ' '|grep -io '[a-z]:\\'|xargs -d'\n' -rI{} sh -c '
		FSUTIL FSINFO VOLUMEINFO "$1"|grep -iq "\bVolume Serial Number\s*:\s*0x$2\b" && echo $1 && exit
	' -- {} "$UUID"))
	[[ -e $DRIVE ]] || die "Drive with id $UUID is not installed"
	echo -n "$DRIVE" && exit
}

exists findmnt && {
	#readlink -ne "$(findmnt -S UUID=$UUID -nro SOURCE)" && exit
	readlink -ne "$(findmnt -S UUID=$UUID -nro TARGET)" && exit
}

exists lsblk && {
	NAME=$(lsblk -lno KNAME,UUID,MOUNTPOINT|awk '$3 ~ /^\// {print $0}'|grep -i "\b$UUID\b"|head -n 1|cut -d' ' -f1)
	[[ -n $NAME ]] && {
		DEV=${NAME:+/dev/$NAME}
		[[ -b $DEV ]] && echo -n "$DEV" && exit
	}
}

[[ -e /dev/disk/by-uuid ]] && {
	readlink -ne "/dev/disk/by-uuid/$UUID" && exit
}

exists blkid && {
	readlink -ne "$(blkid -U "$UUID")" && exit
}

die "Device with id $UUID is not installed"
