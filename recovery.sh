#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR=$(cygpath "$(dirname "$(readlink -f "$0")")")	#Full DIR

function get_json(){
	grep -Po '(?<="'$1'":")(?:|.*?[^\\])(?=")'
}

RESOURCE=$1
BACKUP=$(get_json backup < $RESOURCE)
DISK=$(get_json drive < $RESOURCE)
COMPUTER=$(get_json computer < $RESOURCE)
DPATH=$(get_json path < $RESOURCE )
ENTRY=$(get_json entry < $RESOURCE)

IFS='.' read -r DRIVE VOLUME NAME DESCRIPTION FS <<< "$DISK"
echo $DRIVE
echo $VOLUME
echo $NAME
echo $DESCRIPTION
echo $FS
for DRV in $(fsutil fsinfo drives|sed 's#\r##g;s#\\##g' |cut -d' ' -f2-)
do
  echo drive:'"'$DRV'"'
  fsutil fsinfo volumeinfo $DRV|sed -nE 's/Volume Serial Number\s*:\s*0x'$VOLUME'/'$DRV'/ip'
done
echo -----

. computer.sh       #get $DOMAIN, $NAME and $UUID
THIS=$DOMAIN.$NAME.$UUID
[[ $THIS != $COMPUTER ]] && [[ -n $FORCE ]] && echo This is not the same computer && exit 1; 

CONF="$SDIR/conf/conf.init"
[[ -f $CONF ]] || die Cannot found configuration file at $CONF
. $CONF

RSYNC=$(find "$SDIR/3rd-party" -type f -name "rsync.exe" -print | head -n 1)
[[ -f $RSYNC ]] || die "Rsync.exe not found"

FMT='--out-format="%p|%t|%o|%i|%b|%l|%f"'
PASS="--password-file=$SDIR/conf/pass.txt"
PERM="--acls --owner --group --super --numeric-ids"
OPTIONS="--delete-delay --delay-updates --force --stats --fuzzy"

echo $BACKUP
echo $DISK
echo $COMPUTER
echo $DPATH
echo $ENTRY
