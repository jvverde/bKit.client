#!/usr/bin/env bash
sdir=$(dirname -- "$(readlink -en -- "$0")")  #Full sdir
source "$sdir/../functions/all.sh"

exists wmic && {
  wmic logicalDisk Where DriveType!='6' Get name|tail -n +2| sed 's/\r//g'| sed '/^[[:space:]]*$/d'| sed 's#[[:space:]]*$#\\#'
  exit 0
}
exists fsutil && {
  for DRV in $(fsutil fsinfo drives| tr -d '\r' | sed /^$/d | cut -d' ' -f2-)
  do
    fsutil fsinfo drivetype $DRV|grep -Piq 'Ram\s+Disk' && continue
    echo $DRV
  done
  exit 0
}
exists df && {
  df --output=target -x tmpfs -x devtmpfs |tail -n +2
  exit 0
}
die "neither found fsutil nor df"
