#!/usr/bin/env bash
sdir=$(dirname -- "$(readlink -en -- "$0")")	#Full sdir
source "$sdir/../functions/all.sh"

exists wmic && {
  WMIC logicaldisk WHERE "DriveType!=64" GET Name,VolumeName,VolumeSerialNumber|
    tail -n +2|                   #ignore header line
    tr -d '\r' |                  #remove all carriage returns
    sed '/^[[:space:]]*$/d'|      #remove empty lines
    awk '{print $1"/|"$2"|"$3}'   #formmt output
  exit 0
}

exists df && {
  df --output=target -x tmpfs -x devtmpfs |tail -n +2
  exit 0
}
die "neither found fsutil nor df"
