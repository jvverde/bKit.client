#!/usr/bin/env bash
SDIR="$(dirname -- "$(readlink -ne -- "$0")")"                          #Full DIR

source "$SDIR/functions/all.sh"

DIR="$(readlink -ne -- "$1")"

MOUNT=$(stat -c%m "$DIR")
#Find the top most mount point. We need this for example for BTRFS subvolumes which are mounting points
MOUNT="$(echo "$MOUNT" |fgrep -of <(df --sync --output=target |tail -n +2|sort -r)|head -n1)"

[[ -b $DIR ]] && DEV="$DIR" || {
	exists cygpath && DIR=$(cygpath "$DIR")
	DEV=$(df --output=source "$MOUNT"|tail -1)
}

[[ -b $DEV ]] || {
	#echo try another way >&2
	exists lsblk && DEV="$(lsblk -ln -oNAME,MOUNTPOINT |awk -v m="$MOUNT" '$2 == m {printf("/dev/%s",$1)}')"
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
		local device="$(readlink -ne -- "$DEV")"
		RESULT=$(find /dev/disk/by-id -lname "*/${device##*/}" -print|sort|head -n1 )
		RESULT=${RESULT##*/}
		RESULT=${RESULT%-*}
		VOLUMENAME=${RESULT#*-}
}

readTypeBy() {
		local device="$(readlink -ne -- "$DEV")"
		RESULT=$(find /dev/disk/by-id -lname "*/${device##*/}" -print|sort|head -n1 )
		RESULT=${RESULT##*/}
		DRIVETYPE=${RESULT%%-*}
}

readUUIDby() {
	for U in $(ls /dev/disk/by-uuid)
	do
		[[ "$(readlink -ne -- "$DEV")" == "$(readlink -ne -- "/dev/disk/by-uuid/$U")" ]] && VOLUMESERIALNUMBER="$U" && return 
	done
}

readIDby() {
	for U in $(ls /dev/disk/by-id)
	do
		[[ "$(readlink -ne -- "$DEV")" == "$(readlink -ne "/dev/disk/by-id/$U")" ]] && VOLUMESERIALNUMBER="${U//[^0-9A-Za-z_-]/_}" && return 
	done
}

volume() {
	exists lsblk && {
		VOLUMENAME="$(lsblk -ln -o LABEL "$DEV")"
		true ${VOLUMENAME:=$(lsblk -ln -o PARTLABEL $DEV)}
		true ${VOLUMENAME:=$(lsblk -ln -o VENDOR,MODEL ${DEV%%[0-9]*})}
		true ${VOLUMENAME:=$(lsblk -ln -o MODEL ${DEV%%[0-9]*})}
		true ${FILESYSTEM:="$(lsblk -ln -o FSTYPE "$DEV")"}
		DRIVETYPE=$(lsblk -ln -o TRAN ${DEV%%[0-9]*})
		VOLUMESERIALNUMBER=$(lsblk -ln -o UUID $DEV)
	}
	exists blkid  && {
		true ${FILESYSTEM:=$(blkid "$DEV" |sed -E 's#.*TYPE="([^"]+)".*#\1#')}
		true ${VOLUMESERIALNUMBER:=$(blkid "$DEV" |fgrep 'UUID=' | sed -E 's#.*UUID="([^"]+)".*#\1#')}
	}	

	[[ -n $DRIVETYPE ]] || readTypeBy
	[[ -n $VOLUMESERIALNUMBER ]] || readUUIDby
	[[ -n $VOLUMESERIALNUMBER ]] || readIDby
	[[ -n $VOLUMENAME ]] || readNameBy

	true ${FILESYSTEM:="$(df --output=fstype "$DEV"|tail -n1)"}

	true ${DRIVETYPE:=_}
	true ${VOLUMESERIALNUMBER:=_}
	true ${VOLUMENAME:=_}
	true ${FILESYSTEM:=_}
	
	VOLUMENAME=$(echo $VOLUMENAME| sed -E 's/\s+/_/g')
}


[[ $OS != cygwin ]] && {
	volume		
	echo "$VOLUMENAME|$VOLUMESERIALNUMBER|$FILESYSTEM|$DRIVETYPE" | perl -lape 's/[^a-z0-9._|:+=-]/_/ig'
	exit
} 2>/dev/null

