#!/usr/bin/env bash
die() { echo -e "$@" >&2; exit 1; }
exists() { type "$1" >/dev/null 2>&1;}
OS=$(uname -o |tr '[:upper:]' '[:lower:]')

DIR=$1

[[ -b $DIR ]] && DEV=$DIR || {
	exists cygpath && DIR=$(cygpath "$DIR")
	MOUNT=$(stat -c%m "$DIR")
	DEV=$(df --output=source "$MOUNT"|tail -1)
}

[[ $OS == cygwin ]] && exists wmic && {
	DRIVE=${DEV%%:*} #just left drive letter, nothing else
	LD="$(WMIC logicaldisk WHERE "name like '$DRIVE:'" GET VolumeName,FileSystem,VolumeSerialNumber,drivetype /format:textvaluelist|
		tr -d '\r'|
		sed -r '/^$/d;s/^\s+|\s+$//;s/\s+/_/g'
	)"
	
	FS=$(awk -F '=' 'tolower($1) ~  /filesystem/ {print $2}' <<<"$LD")
	VN=$(awk -F '=' 'tolower($1) ~  /volumename/ {print $2}' <<<"$LD")
	SN=$(awk -F '=' 'tolower($1) ~  /volumeserialnumber/ {print $2}' <<<"$LD")
	DT=$(awk -F '=' 'tolower($1) ~  /drivetype/ {print $2}' <<<"$LD")
	echo "${VN:-_}|${SN:-_}|${FS:-_}|${DT:-_}"
	exit
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
	exit
} 2>/dev/null

readNameBy() {
		RESULT=$(find /dev/disk/by-id -lname "*/${DEV##*/}" -print|sort|head -n1 )
		RESULT=${RESULT##*/}
		RESULT=${RESULT%-*}
		VOLUMENAME=${RESULT#*-}
}

readTypeBy() {
		RESULT=$(find /dev/disk/by-id -lname "*/${DEV##*/}" -print|sort|head -n1 )
		RESULT=${RESULT##*/}
		DRIVETYPE=${RESULT%%-*}
}

readUUIDby() {
	for U in $(ls /dev/disk/by-uuid)
	do
		[[ "$DEV" == "$(readlink -ne "/dev/disk/by-uuid/$U")" ]] && VOLUMESERIALNUMBER="$U" && return 
	done
}

readIDby() {
	for U in $(ls /dev/disk/by-id)
	do
		[[ "$DEV" == "$(readlink -ne "/dev/disk/by-id/$U")" ]] && VOLUMESERIALNUMBER="${U//[^0-9A-Za-z_-]/_}" && return 
	done
}

volume() {
	FILESYSTEM="$(df --output=fstype "$DEV"|tail -n1)"
	exists lsblk && {
		VOLUMENAME="$(lsblk -ln -o LABEL "$DEV")"
		true ${VOLUMENAME:=$(lsblk -ln -o PARTLABEL $DEV)}
		true ${VOLUMENAME:=$(lsblk -ln -o VENDOR,MODEL ${DEV%%[0-9]*})}
		true ${VOLUMENAME:=$(lsblk -ln -o MODEL ${DEV%%[0-9]*})}
		DRIVETYPE=$(lsblk -ln -o TRAN ${DEV%%[0-9]*})
		VOLUMESERIALNUMBER=$(lsblk -ln -o UUID $DEV)
		true ${FILESYSTEM:="$(lsblk -ln -o FSTYPE "$DEV")"}
	}
	exists blkid  && {
		true ${FILESYSTEM:=$(blkid "$DEV" |sed -E 's#.*TYPE="([^"]+)".*#\1#')}
		true ${VOLUMESERIALNUMBER:=$(blkid "$DEV" |fgrep 'UUID=' | sed -E 's#.*UUID="([^"]+)".*#\1#')}
	}	

	[[ -n $DRIVETYPE ]] || readTypeBy
	[[ -n $VOLUMESERIALNUMBER ]] || readUUIDby
	[[ -n $VOLUMESERIALNUMBER ]] || readIDby
	[[ -n $VOLUMENAME ]] || readNameBy

	true ${DRIVETYPE:=_}
	true ${VOLUMESERIALNUMBER:=_}
	true ${VOLUMENAME:=_}
	true ${FILESYSTEM:=_}
	
	VOLUMENAME=$(echo $VOLUMENAME| sed -E 's/\s+/_/g')
}


[[ $OS != cygwin ]] && {
	volume		
	echo "$VOLUMENAME|$VOLUMESERIALNUMBER|$FILESYSTEM|$DRIVETYPE"
	exit
} 2>/dev/null

