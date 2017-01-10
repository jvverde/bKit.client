#!/bin/bash
[[ -n $1 ]] || echo -e "Usage:\n\t$0 VolumeId"
for DRV in $(fsutil fsinfo drives|sed 's/\r//g;s/\\//g' |cut -d' ' -f2-)
do
  fsutil fsinfo drivetype $DRV|grep -Piq 'Ram\s+Disk' && continue
  fsutil fsinfo volumeinfo $DRV|grep -Piq '^\s*Volume\s+Serial\s+Number\s*:\s*0x'$1'\s*$' || continue
  echo $DRV && exit 0
done
exit 1