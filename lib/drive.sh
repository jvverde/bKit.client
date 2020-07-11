#!/usr/bin/env bash

_use_wmic(){
	declare -r dev="$1"
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

_use_fsutil(){
	declare -r dev="$1"
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

_readNameBy() {
	declare -r dev="$1"
	local device="$(readlink -ne -- "$dev")"
	RESULT="$(find /dev/disk/by-id -lname "*/${device##*/}" -print|sort|head -n1 )"
	RESULT="${RESULT##*/}"
	RESULT="${RESULT%-*}"
	VOLUMENAME="${RESULT#*-}"
}

_readTypeBy() {
	declare -r dev="$1"
	local device="$(readlink -ne -- "$dev")"
	RESULT=$(find /dev/disk/by-id -lname "*/${device##*/}" -print|sort|head -n1 )
	RESULT=${RESULT##*/}
	DRIVETYPE=${RESULT%%-*}
}

_readUUIDby() {
	declare -r dev="$1"
	for U in $(ls /dev/disk/by-uuid)
	do
		[[ "$(readlink -ne -- "$dev")" == "$(readlink -ne -- "/dev/disk/by-uuid/$U")" ]] && VOLUMESERIALNUMBER="$U" && return 
	done
}

_readIDby() {
	declare -r dev="$1"
	for U in $(ls /dev/disk/by-id)
	do
		[[ "$(readlink -ne -- "$dev")" == "$(readlink -ne "/dev/disk/by-id/$U")" ]] && VOLUMESERIALNUMBER="${U//[^0-9A-Za-z_-]/_}" && return 
	done
}

_volume() {
	declare -r dev="$1"
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

	[[ -n $DRIVETYPE ]] || _readTypeBy "$dev"
	[[ -n $VOLUMESERIALNUMBER ]] || _readUUIDby "$dev"
	[[ -n $VOLUMESERIALNUMBER ]] || _readIDby "$dev"
	[[ -n $VOLUMENAME ]] || _readNameBy "$dev"

	true ${FILESYSTEM:="$(df --output=fstype "$dev"|tail -n1)"}

	true ${DRIVETYPE:=_}
	true ${VOLUMESERIALNUMBER:=_}
	true ${VOLUMENAME:=_}
	true ${FILESYSTEM:=_}
	
	VOLUMENAME=$(echo $VOLUMENAME| sed -E 's/\s+/_/g')
}

_use_linux() {
	declare -r dev="$1"
	_volume "$dev"		
	echo "$VOLUMENAME|$VOLUMESERIALNUMBER|$FILESYSTEM|$DRIVETYPE" | perl -lape 's/[^a-z0-9._|:+=-]/_/ig'	
}

#Find a method, run it and exit
_drive(){
	declare -r sdir="$(dirname -- "$(readlink -ne -- "${BASH_SOURCE[0]}")")"
	source "$sdir/functions/messages.sh"                          #Full dir
	declare -r dir="$(readlink -nm -- "$1" || warn "Cannot readlink for '$1'")"
	declare -r dev="$($sdir/dir2dev.sh "$dir" || warn "Cannot get a dev for '$dir'")"

	[[ ${BKITCYGWIN+x} == x ]] && exists wmic && _use_wmic "$dev" && return
	[[ ${BKITCYGWIN+x} == x ]] && exists fsutil && _use_fsutil "$dev" && return

	[[ ${BKITCYGWIN+x} != x ]] && _use_linux "$dev" 2>/dev/null && return

	warn 'Not find a method to use'	
}

_drives(){
	for src in "${@:-.}"
	do	
		_drive "$src"
	done
}

_exportdrive() {
	declare -gx BKITDRIVE="$(_drive "${1:-.}")"
}

${__SOURCED__:+return} #Intended for shellspec tests

if [[ "${BASH_SOURCE[0]}" == "$0" ]] #if not sourced
then
	_drives "$@"
else
	_exportdrive "${1:-.}"
fi