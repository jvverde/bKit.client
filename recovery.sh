#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR=$(cygpath "$(dirname "$(readlink -f "$0")")")	#Full DIR

function get_json(){
	grep -Po '(?<="'$1'":")(?:|.*?[^\\])(?=")'
}

RESOURCE=$1
BACKUP=$(get_json backup < $RESOURCE)
DRIVE=$(get_json drive < $RESOURCE)
COMPUTER=$(get_json computer < $RESOURCE)
DPATH=$(get_json path < $RESOURCE )
ENTRY=$(get_json entry < $RESOURCE)

. computer.sh
echo $UUID
echo $NAME
echo $DOMAIN
THIS=$DOMAIN.$NAME.$UUID
[[ $THIS != $COMPUTER ]] && [[ -n $FORCE ]] && echo This is not the same computer && exit 1; 
echo $BACKUP
echo $DRIVE
echo $COMPUTER
echo $DPATH
echo $ENTRY
