#!/usr/bin/env bash
SDIR=$(dirname -- "$(readlink -en -- "$0")")	#Full SDIR
source "$SDIR/lib/functions/all.sh"


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
