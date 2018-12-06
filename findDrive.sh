#!/usr/bin/env bash
SDIR="$(dirname "$(readlink -f "$0")")"       #Full DIR
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
  exit 1
}

set -o pipefail

bash "$SDIR/getdev.sh" "$UUID" |xargs -I{} df --output=target "{}"|tail -n 1
