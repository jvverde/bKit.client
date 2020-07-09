#!/usr/bin/env bash
declare -r sdir="$(dirname -- "$(readlink -ne -- "$0")")"                          #Full dir

source "$sdir/functions/all.sh"

declare dir="$(readlink -ne -- "${1:-.}")"

#mountpoint=$(stat -c%m "$dir")
#Find the top most mountpoint point. We need this for example for BTRFS subvolumes which are mountpointing points
#mountpoint="$(echo "$mountpoint" |fgrep -of <(df --sync --output=target |tail -n +2|sort -r)|head -n1)"

#[[ -b $dir ]] && dev="$dir" || {
#	exists cygpath && dir=$(cygpath "$dir")
#	dev=$(df --output=source "$mountpoint"|tail -1)
#}
declare dev=""

if [[ -b $dir ]]
then
	dev="$dir"
else
	declare mountpoint=""
	mountpoint="$(stat -c%m "$dir")" || die "Cannot find mountpoint point of '$dir'"
	#Find the top most mountpoint point. We need this for example for BTRFS subvolumes which are mountpointing points
	mountpoint="$(echo "$mountpoint" |fgrep -of <(df --sync --output=target |tail -n +2|sort -r)|head -n1)"
	[[ ${BKITCYGWIN+x} == x ]] && exists cygpath && dir=$(cygpath "$dir")
	
	dev=$(df --output=source "$mountpoint"|tail -1)
	[[ ${BKITCYGWIN+x} != x && ! -b $dev ]] && exists lsblk && {
		#echo try another way >&2
		dev="$(lsblk -ln -oNAME,MOUNTPOINT |awk -v m="$mountpoint" '$2 == m {printf("/dev/%s",$1)}')"
	}
fi

use_wmic(){
	DRIVE=${dev%%:*} #just left drive letter, nothing else
	LD="$(WMIC logicaldisk WHERE "name like '$DRIVE:'" GET VolumeName,FileSystem,VolumeSerialNumber,drivetype /format:textvaluelist|
		tr -d '\r'|
		sed -r '/^$/d;s/^\s+|\s+$//;s/\s+/_/g'
	)"
	
	FS=$(awk -F '=' 'tolower($1) ~  /filesystem/ {print $2}' <<<"$LD")
	VN=$(awk -F '=' 'tolower($1) ~  /volumename/ {print $2}' <<<"$LD")
	SN=$(awk -F '=' 'tolower($1) ~  /volumeserialnumber/ {print $2}' <<<"$LD")
	DT=$(awk -F '=' 'tolower($1) ~  /drivetype/ {print $2}' <<<"$LD")
	echo "${VN:-_}|${SN:-_}|${FS:-_}|${DT:-_}"
}

use_fsutil(){
	DRIVE=${dev%%:*} #just left drive letter, nothing else
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

readNameBy() {
		local device="$(readlink -ne -- "$dev")"
		RESULT="$(find /dev/disk/by-id -lname "*/${device##*/}" -print|sort|head -n1 )"
		RESULT="${RESULT##*/}"
		RESULT="${RESULT%-*}"
		VOLUMENAME="${RESULT#*-}"
}

readTypeBy() {
		local device="$(readlink -ne -- "$dev")"
		RESULT=$(find /dev/disk/by-id -lname "*/${device##*/}" -print|sort|head -n1 )
		RESULT=${RESULT##*/}
		DRIVETYPE=${RESULT%%-*}
}

readUUIDby() {
	for U in $(ls /dev/disk/by-uuid)
	do
		[[ "$(readlink -ne -- "$dev")" == "$(readlink -ne -- "/dev/disk/by-uuid/$U")" ]] && VOLUMESERIALNUMBER="$U" && return 
	done
}

readIDby() {
	for U in $(ls /dev/disk/by-id)
	do
		[[ "$(readlink -ne -- "$dev")" == "$(readlink -ne "/dev/disk/by-id/$U")" ]] && VOLUMESERIALNUMBER="${U//[^0-9A-Za-z_-]/_}" && return 
	done
}

volume() {
	exists lsblk && {
		VOLUMENAME="$(lsblk -ln -o LABEL "$dev")"
		true ${VOLUMENAME:=$(lsblk -ln -o PARTLABEL $dev)}
		true ${VOLUMENAME:=$(lsblk -ln -o VENDOR,MODEL ${dev%%[0-9]*})}
		true ${VOLUMENAME:=$(lsblk -ln -o MODEL ${dev%%[0-9]*})}
		true ${FILESYSTEM:="$(lsblk -ln -o FSTYPE "$dev")"}
		DRIVETYPE=$(lsblk -ln -o TRAN ${dev%%[0-9]*})
		VOLUMESERIALNUMBER=$(lsblk -ln -o UUID $dev)
	}
	exists blkid  && {
		true ${FILESYSTEM:=$(blkid "$dev" |sed -E 's#.*TYPE="([^"]+)".*#\1#')}
		true ${VOLUMESERIALNUMBER:=$(blkid "$dev" |fgrep 'UUID=' | sed -E 's#.*UUID="([^"]+)".*#\1#')}
	}	

	[[ -n $DRIVETYPE ]] || readTypeBy
	[[ -n $VOLUMESERIALNUMBER ]] || readUUIDby
	[[ -n $VOLUMESERIALNUMBER ]] || readIDby
	[[ -n $VOLUMENAME ]] || readNameBy

	true ${FILESYSTEM:="$(df --output=fstype "$dev"|tail -n1)"}

	true ${DRIVETYPE:=_}
	true ${VOLUMESERIALNUMBER:=_}
	true ${VOLUMENAME:=_}
	true ${FILESYSTEM:=_}
	
	VOLUMENAME=$(echo $VOLUMENAME| sed -E 's/\s+/_/g')
}

use_linux() {
	volume		
	echo "$VOLUMENAME|$VOLUMESERIALNUMBER|$FILESYSTEM|$DRIVETYPE" | perl -lape 's/[^a-z0-9._|:+=-]/_/ig'	
}

#Check $dev
[[ -z $dev ]] && die "I couldn't find a dev for $dir" 

[[ ${BKITCYGWIN+x} == x && ! $dev =~ ^.: ]] && die "'$dev' isn't valid disc"
[[ ${BKITCYGWIN+x} != x && ! -b $dev ]] && die "'$dev' isn't valid block device"

#Find a method, run it and exit
[[ ${BKITCYGWIN+x} == x ]] && exists wmic && use_wmic && exit
[[ ${BKITCYGWIN+x} == x ]] && exists fsutil && use_fsutil && exit

[[ ${BKITCYGWIN+x} != x ]] && use_linux 2>/dev/null && exit

die 'Not find a method to use'

