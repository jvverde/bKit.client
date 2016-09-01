#!/bin/bash
die() { echo -e "$@"; exit 1; }
[[ $1 == '-f' ]] && FULL=true && shift				#get -f option if present
SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR
FULLPATH="$(readlink -e $1)"
MOUNT="$(stat -c %m $FULLPATH)"
DIR="${FULLPATH#$MOUNT}"
DIR="${DIR#/}"

DEV=$(fgrep $MOUNT /proc/mounts | cut -d' ' -f1)
. ./drive.sh $DEV || die Cannot execute drive.sh $DEV

CACHE="$SDIR/cache/hashes/by-volume/$VOLUMESERIALNUMBER/$DIR"
MARK="$CACHE/.marktime"
mkdir -pv "$CACHE"
WD="$SDIR/run"
mkdir -p "$WD"
INITTIME="$WD/.inittime"
FILES="$WD/$$.files"
HASHES="$WD/$$.hash"
RESULT="$WD/$$.lst"
NEW="$CACHE/new.lst"
FINAL="$CACHE/all.lst"

[[ -e $FINAL ]] || touch "$FINAL"
cd $MOUNT
LC_ALL=C
touch "$INITTIME"
NEWER="$([[ -z $FULL && -e "$MARK" && -s "$FINAL" && ! "$FINAL" -ot "$MARK" ]] && echo -newer $MARK)"

find "./$DIR" -ignore_readdir_race -xdev -type f $NEWER -printf "%s|%T@|%p\n"|
	tee "$FILES"|
	cut -d'|' -f3|
	xargs -r -d '\n' sha256sum -b|
	sed -e 's/\s*\*/|/'> "$HASHES"
cd "$WD"
if [[ -s "$FILES" && -s "$HASHES" ]]
then
	join -t '|' -1 3 -2 2 -o 2.1,1.1,1.2,1.3 <(sort -t'|' -k3 "$FILES") <(sort -t'|' -k2 "$HASHES") | #join files and hashes
		sort -t'|' -k4,4 -k3,3nr -o "$NEW"																															#and then save it on NEW file

	sort -m -u -t'|' -k4,4 -k3,3nr -o "$RESULT" <(		 #merge old and new and sort by filename (k4) and mofification time (k3) with newest first (nr)
		sort -t'|' -k4,4 -k3,3nr "$FINAL"	 #get old sorted -- just in case
	) $NEW 
	awk -F'|' 'last!=$4 {print}{last=$4}' "$RESULT" > "$FINAL"
	mv -f "$INITTIME" "$MARK"
	rm -f "$RESULT" 
	echo $NEW
fi
rm -f "$FILES" "$HASHES"



