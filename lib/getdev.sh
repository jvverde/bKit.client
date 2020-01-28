#!/usr/bin/env bash
sdir="$(dirname "$(readlink -f "$0")")"				#Full DIR

source "$sdir/functions/all.sh"

[[ ${1+isset} == isset ]] || die "Usage:\n\t$0 uuid"

uuid="$1"

exists wmic && {
	echo -n "$(WMIC logicaldisk WHERE "VolumeSerialNumber like '$uuid' and DriveType!=64" GET Name /format:textvaluelist | sed -nr 's/Name=(.+)/\1/p' | perl -lape 's/(?:\r|\n)+$//g'|head -n1)" && exit
}

exists fsutil && {
	drive=($(FSUTIL FSINFO DRIVES|sed 's/\r//g;/^$/d'|tr '\0' ' '|grep -io '[a-z]:\\'|xargs -d'\n' -rI{} sh -c '
		FSUTIL FSINFO VOLUMEINFO "$1"|grep -iq "\bVolume Serial Number\s*:\s*0x$2\b" && echo $1 && exit
	' -- {} "$uuid"))
	[[ -e $drive ]] || die "Drive with id $uuid is not installed"
	echo -n "$drive" && exit
}

exists findmnt && {
	#readlink -ne "$(findmnt -S uuid=$uuid -nro SOURCE)" && exit
	readlink -ne "$(findmnt -S UUID=$uuid -nro TARGET)" && exit
}

exists lsblk && {
	name="$(lsblk -lno KNAME,UUID,MOUNTPOINT|awk '$3 ~ /^\// {print $0}'|grep -i "\b$uuid\b"|head -n 1|cut -d' ' -f1)"
	[[ -n $name ]] && {
		DEV=${name:+/dev/$name}
		[[ -b $DEV ]] && echo -n "$DEV" && exit
	}
}

[[ -e /dev/disk/by-uuid ]] && {
	readlink -ne "/dev/disk/by-uuid/$uuid" && exit
}

exists blkid && {
	readlink -ne "$(blkid -U "$uuid")" && exit
}

die "Device with id $uuid is not installed"
