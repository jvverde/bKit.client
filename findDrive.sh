#!/bin/bash
[[ -n $1 ]] || echo -e "Usage:\n\t$0 VolumeId"
UUID=$1
die() { echo -e "$@">&2; exit 1; }
exists() { type "$1" >/dev/null 2>&1;}
exists fsutil && {
  for DRV in $(fsutil fsinfo drives|sed 's/\r//g;s/\\//g' |cut -d' ' -f2-)
  do
    fsutil fsinfo drivetype $DRV|grep -Piq 'Ram\s+Disk' && continue
    fsutil fsinfo volumeinfo "$DRV\\"|grep -Piq '^\s*Volume\s+Serial\s+Number\s*:\s*0x'$UUID'\s*$' || continue
    echo $DRV && exit 0
  done
}
exists lsblk && exec 3>&2 &&{
  [[ $UID -eq 0 ]] || die $0 must be run as root>&3
  MOUNT=$(lsblk -Pno UUID,MOUNTPOINT|fgrep "UUID=\"$UUID\""|grep -Po '(?<=MOUNTPOINT=")([^"]|\\")*(?=")')
  [[ -z $MOUNT ]] && MOUNT="/dev/$(lsblk -Pno UUID,KNAME|fgrep "UUID=\"$UUID\""|grep -Po '(?<=KNAME=")([^"]|\\")*(?=")')"
  echo $MOUNT && exit 0
} #2>/dev/null
exit 1