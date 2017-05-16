#!/bin/bash
die() { echo -e "$@">&2; exit 1; }
exists() { type "$1" >/dev/null 2>&1;}

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
