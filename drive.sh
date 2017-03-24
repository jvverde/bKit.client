#!/bin/bash
die() { echo -e "$@" >&2; exit 1; }
exists() { type "$1" >/dev/null 2>&1;}
OS=$(uname -o |tr '[:upper:]' '[:lower:]')

DIR=$1

[[ -b $DIR ]] && DEV=$DIR || {
	exists cygpath && DIR=$(cygpath "$DIR")
	MOUNT=$(stat -c%m "$DIR")
	DEV=$(df --output=source "$MOUNT"|tail -1)
}

[[ $OS == cygwin ]] && exists fsutil && {
	DRIVE=${DEV%%:*} #just left drive letter, nothing else
	VOLUMEINFO="$(fsutil fsinfo volumeinfo $DRIVE:\\ | tr -d '\r')"
	VOLUMENAME=$(echo -e "$VOLUMEINFO"| awk -F ":" 'toupper($1) ~ /VOLUME NAME/ {print $2}' |
		sed -E 's/^\s*//;s/\s*$//;s/[^a-z0-9]/-/gi;s/^$/_/;s/\s/_/g'
	)
	VOLUMESERIALNUMBER=$(echo -e "$VOLUMEINFO"| awk -F ":" 'toupper($1) ~ /VOLUME SERIAL NUMBER/ {print toupper($2)}' |
		sed -E 's/^\s*//;s/\s*$//;s/^0x//gi;s/^$/_/;s/\s/_/g'
	)
	FILESYSTEM=$(echo -e "$VOLUMEINFO"| awk -F ":" 'toupper($1) ~ /FILE SYSTEM NAME/ {print $2}' |
		sed -E 's/^\s*//;s/\s*$//;s/^0x//gi;s/^$/_/;s/\s/_/g'
	)
	DRIVETYPE=$(fsutil fsinfo driveType $DRIVE: | tr -d '\r'|
		sed -e "s/^$DRIVE:.*- *//" | sed -E 's/[^a-z0-9]/-/gi;s/^$/_/;s/\s/_/g'
	)
	echo "$VOLUMENAME|$VOLUMESERIALNUMBER|$FILESYSTEM|$DRIVETYPE"
} 2>/dev/null

[[ $OS != cygwin ]] && exists lsblk && exec 3>&2 && {
	[[ $UID -eq 0 ]] || die $0 must be run as root>&3
	VOLUMENAME=$(lsblk -ln -o LABEL $DEV)
	true ${VOLUMENAME:=$(lsblk -ln -o PARTLABEL $DEV)}
	true ${VOLUMENAME:=$(lsblk -ln -o VENDOR,MODEL ${DEV%%[0-9]*})}
	true ${VOLUMENAME:=$(lsblk -ln -o MODEL ${DEV%%[0-9]*})}
	VOLUMENAME=$(echo $VOLUMENAME| sed -E 's/\s+/_/g')
	FILESYSTEM=$(lsblk -ln -o FSTYPE $DEV)
	DRIVETYPE=$(lsblk -ln -o TRAN ${DEV%%[0-9]*})
	true ${DRIVETYPE:=$(
		RESULT=$(find /dev/disk/by-id -lname "*/${DEV##*/}" -print|sort|head -n1 )
		RESULT=${RESULT##*/}
		echo ${RESULT%%-*}
	)}
	VOLUMESERIALNUMBER=$(lsblk -ln -o UUID $DEV)
	echo "$VOLUMENAME|$VOLUMESERIALNUMBER|$FILESYSTEM|$DRIVETYPE"
} 2>/dev/null
