#!/bin/bash
die() { echo -e "$@"; exit 1; }
[[ $1 == '-f' ]] && FULL=true && shift				#get -f option if present
[[ $1 == '-l' ]] && LIST=true && shift				#get -l option if present

SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR
FULLPATH="$(readlink -e "$1")"
[[ -d $FULLPATH ]] || die Directory $FULLPATH does not exist

MOUNT="$(stat -c %m "$FULLPATH")"
DIR="${FULLPATH#$MOUNT}"
DIR="${DIR#/}"

DEV=$(fgrep $MOUNT /proc/mounts | cut -d' ' -f1)
. ./drive.sh $DEV || die Cannot execute drive.sh $DEV

CACHE="$SDIR/cache/hashes/by-volume/$VOLUMESERIALNUMBER/$DIR"
MARK="$CACHE/.marktime"
WD="$SDIR/run"
INITTIME="$WD/.inittime"
FILES="$WD/$$.files"
HASHES="$WD/$$.hash"
RESULT="$WD/$$.lst"
NEW="$CACHE/new.lst"
FINAL="$CACHE/hashes.db"
[[ -n $LIST && -e $FINAL ]] && echo $FINAL && exit
[[ -n $LIST && ! -e "$FINAL" ]] && exit 1

mkdir -pv "$CACHE"
mkdir -p "$WD"


type sqlite3>/dev/null || die Cannot found sqlite3

DB="$(cygpath -w "$FINAL")"
echo DB=$DB

sqlite3 "$DB" "CREATE TABLE IF NOT EXISTS H(hash TEXT, filename TEXT PRIMARY KEY)" || die Cannot open DB $DB
LC_ALL=C
touch "$INITTIME"

cd $MOUNT
{
	PREFIX=${DIR:+$DIR/}
	FORMAT="%s|%T@|${PREFIX}%P\n"
	if [[ -z $FULL && -e "$MARK" && -s "$FINAL" && ! "$FINAL" -ot "$MARK" ]]
	then
		find "./$DIR" -ignore_readdir_race -xdev -type f -newer "$MARK" -printf "$FORMAT"
	else
		find "./$DIR" -ignore_readdir_race -xdev -type f -printf "$FORMAT"
	fi
}|tee "$FILES"|cut -d'|' -f3|xargs -r -d '\n' sha256sum -b|(
	echo "INSERT OR REPLACE INTO H"
	sed -E "1s/([0-9A-Z]*)\s*\*(.*)/SELECT '\1' as 'hash', '\2' as 'filename'/i; 1 ! s/([0-9A-Z]*)\s*\*(.*)/UNION ALL SELECT '\1','\2'/i"
	echo ';'
)
#|sqlite3 "$DB" 


exit
cd "$WD"
if [[ -s "$FILES" && -s "$HASHES" ]]
then
	join -t '|' -1 3 -2 2 -o 2.1,1.1,1.2,1.3 <(sort -t'|' -k3 "$FILES") <(sort -t'|' -k2 "$HASHES") | #join files and hashes
		sort -t'|' -k4,4 -k3,3nr | tee "$NEW"																															#and then save it on NEW file
	
	sort -m -u -t'|' -k4,4 -k3,3nr -o "$RESULT" <(		 #merge old and new and sort by filename (k4) and mofification time (k3) with newest first (nr)
		sort -t'|' -k4,4 -k3,3nr "$FINAL"	 							 #get old sorted -- just in case
	) "$NEW" 
	awk -F'|' 'last!=$4 {print}{last=$4}' "$RESULT" > "$FINAL"
	mv -f "$INITTIME" "$MARK"
	rm -f "$RESULT" 
fi
rm -f "$FILES" "$HASHES"



