#!/usr/bin/env bash
sdir=$(dirname -- "$(readlink -en -- "$0")")	#Full sdir
source "$sdir/functions/all.sh"

exists wmic && {
  WMIC logicaldisk WHERE "DriveType!=64" GET Name,VolumeName,VolumeSerialNumber|
    tail -n +2|                   #ignore header line
    tr -d '\r' |                  #remove all carriage returns
    sed '/^[[:space:]]*$/d'|      #remove empty lines
    awk '{print $1"/|"$2"|"$3}'   #formmt output
  exit 0
}


getLabel() {
  declare dev="$1"
  declare -g label=''
  exists findmnt && label="$(findmnt -nro LABEL "$dev")"
  [[ -z $label && -b $dev ]] && exists lsblk && label="$(lsblk -nro LABEL "$dev")"
  [[ -z $label && -e /dev/disk/by-label ]] && label="$(find /dev/disk/by-label -lname "*/${dev##*/}" -printf "%f" -quit)" 
}
getUUID() {
  declare dev="$1"
  declare -g uuid=''
  exists findmnt && uuid="$(findmnt -nro UUID "$dev")"
  [[ -z $uuid && -b $dev ]] && exists lsblk && uuid="$(lsblk -nro UUID "$dev")"
  [[ -z $uuid && -e /dev/disk/by-uuid ]] && uuid="$(find /dev/disk/by-uuid -lname "*/${dev##*/}" -printf "%f" -quit)" 
}
exists df && {
  df --output=source,target,fstype -x tmpfs -x devtmpfs -x squashfs |tail -n +2|
  while read src mnt type
  do
    getLabel "$src"
    getUUID "$src"
    echo "$src|$mnt|${label:-_}|${uuid:-_}|${type:-_}"
  done
  exit 0
}
die "neither found fsutil nor df"
