#!/bin/bash
die() { echo -e "$@"; exit 1; }
exists() { type "$1" >/dev/null 2>&1;}
[[ $1 == '-f' ]] && FULL=true && shift				#get -f option if present
[[ $1 == '-l' ]] && LIST=true && shift				#get -l option if present
[[ $1 == '-b' ]] && LBD=true && shift				#get -l option if present

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
NEW="$CACHE/new.csv"
FINAL="$CACHE/all.csv"
DB="$CACHE/hashes.db"
exists cygpath && DB=$(cygpath -w "$DB")

[[ -n $LIST && -e $FINAL ]] && echo $FINAL && exit
[[ -n $LIST ]] && exit 1
[[ -n $LBD && -e $DB ]] && echo $DB && exit
[[ -n $LDB ]] && exit 1

mkdir -pv "$CACHE"
mkdir -p "$WD"

[[ -e $FINAL ]] || touch "$FINAL"

LC_ALL=C
touch "$INITTIME"

cd $MOUNT
{
	PREFIX=${DIR:+$DIR/}
	FORMAT="%s|%T@|${PREFIX}%P\n"
	if [[ -z $FULL && -e "$MARK" && -s "$FINAL" && ! "$FINAL" -ot "$MARK" && -s "$DB" && ! "$DB" -ot "$FINAL" ]]
	then
		find "./$DIR" -ignore_readdir_race -xdev -type f -newer "$MARK" -printf "$FORMAT"
	else
		find "./$DIR" -ignore_readdir_race -xdev -type f -printf "$FORMAT"
	fi
}|tee >(sort -t'|' -k3 -o "$FILES")|cut -d'|' -f3|xargs -r -d '\n' sha256sum -b|sed -E 's/\s+\*/|/'|(sort -t'|' -k2 -o "$HASHES")

#join hashes with sizes and times, output it to stdout, and also save it on NEW tmp file
join -t '|' -1 3 -2 2 -o 2.1,1.1,1.2,1.3 "$FILES" "$HASHES" | sort -t'|' -k4,4 -k3,3nr | tee "$NEW"																															#and then save it on NEW file

#merge FINAL with NEW, remove the duplicate files (old hashes) and save it on a temporary file
sort -t'|' -k4,4 -k3,3nr "$FINAL" | sort -m -u -t'|' -k4,4 -k3,3nr - "$NEW" | awk -F'|' 'last!=$4 {print}{last=$4}' > "${FINAL}.tmp"

mv -f "${FINAL}.tmp" "${FINAL}"
mv -f "$INITTIME" "$MARK"

exists sqlite3 || die Cannot fine sqlite3
{
	# echo "DROP TABLE IF EXISTS H;"
	# echo "CREATE TABLE IF NOT EXISTS H(hash TEXT, size INT, time REAL,filename TEXT PRIMARY KEY);"
	# echo '.separator "|"'
	# echo ".import '$FINAL' H"
	echo "DROP TABLE IF EXISTS TMP;"
	echo "CREATE TABLE TMP(hash TEXT, size INT, time REAL,filename TEXT);"
	echo "CREATE TABLE IF NOT EXISTS H(hash TEXT, size INT, time REAL,filename TEXT PRIMARY KEY);"
	echo '.separator "|"'
	echo ".import '$NEW' TMP"
	echo "INSERT OR REPLACE INTO H SELECT * FROM TMP;"
	echo "DROP TABLE IF EXISTS TMP;"
}|sqlite3 "$DB" 

rm -f "$FILES" "$HASHES"



