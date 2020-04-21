#!/usr/bin/env bash
sdir=$(dirname -- "$(readlink -en -- "$0")")	#Full sdir
source "$sdir/functions/all.sh"

exists wmic && {
  WMIC logicaldisk WHERE "DriveType!=64" GET FileSystem,Name,VolumeName,VolumeSerialNumber /format:csv|
    tr -d '\r' |                  #remove all carriage returns
    sed '/^[[:space:]]*$/d'|      #remove empty lines
    tail -n +2|                   #ignore header line
    awk -F, '{print $3"\\|"$4"|"$5"|"$2}'   #format output letter:/|label|uuid|fstype
  exit 0
}

#This is for linux
getLabel() {
  declare dev="$1"
  declare -g label=''
  exists findmnt && label="$(findmnt -nro LABEL "$dev"|head -n1)"
  [[ -z $label && -b $dev ]] && exists lsblk && label="$(lsblk -nro LABEL "$dev")"
  [[ -z $label && -e /dev/disk/by-label ]] && label="$(find /dev/disk/by-label -lname "*/${dev##*/}" -printf "%f" -quit)" 
}
getUUID() {
  declare dev="$1"
  declare -g uuid=''
  exists findmnt && uuid="$(findmnt -nro UUID "$dev" | head -n1)"
  [[ -z $uuid && -b $dev ]] && exists lsblk && uuid="$(lsblk -nro UUID "$dev")"
  [[ -z $uuid && -e /dev/disk/by-uuid ]] && uuid="$(find /dev/disk/by-uuid -lname "*/${dev##*/}" -printf "%f" -quit)" 
}
exists df && {
  df --output=source,target,fstype -x tmpfs -x devtmpfs -x squashfs |tail -n +2|
  while read src mnt type
  do
    getLabel "$src"
    getUUID "$src"
    echo "$mnt|$label|$uuid|$type"
  done
  exit 0
}
die "neither found fsutil nor df"
