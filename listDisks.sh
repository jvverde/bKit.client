#!/bin/bash
die() { echo -e "$@">&2; exit 1; }
exists() { type "$1" >/dev/null 2>&1;}

exists fsutil && {
  for DRV in $(fsutil fsinfo drives|sed 's/\r|\n//g;s/\\//g' |cut -d' ' -f2-)
  do
    fsutil fsinfo drivetype $DRV|grep -Piq 'Ram\s+Disk' && continue
    echo $DRV
  done
  exit 0
}
exists lsblk && exec 3>&2 &&{

}
die neither found fsutil nor lsblk
