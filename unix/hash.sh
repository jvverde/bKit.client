#!/bin/bash
FULLPATH=$(readlink -e $1)
MARK=$2
MOUNT=$(stat -c %m $FULLPATH)
DIR=${FULLPATH#$MOUNT}
DIR=${DIR#/}
touch $$.inittime
CD=$(pwd)
cd $MOUNT
LC_ALL=C
find "./$DIR" -ignore_readdir_race -xdev -type f $([[ -f $CD/$MARK ]] && echo -newer $CD/$MARK) -printf "%s|%T@|%p\n"|
	tee $CD/$$.files|
	cut -d'|' -f3|
	xargs -d '\n' sha256sum -b|
	sed -e 's/\s*\*/|/'> $CD/$$.hash
cd $CD
join -t '|' -a 1 -e _  -1 3 -2 2 -o 2.1,1.1,1.2,1.3 <(sort -t'|' -k3 $$.files) <(sort -t'|' -k2 $$.hash) 
[[ -n $MARK ]] && mv -f $$.inittime "$MARK"
