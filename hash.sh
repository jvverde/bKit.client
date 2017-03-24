#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
die() { echo -e "$@">&2; exit 1; }
exists() { type "$1" >/dev/null 2>&1 ;}

exists sqlite3 || die Cannot find sqlite3


[[ $1 == '-f' ]] && FULL=true && shift				#get -f option if present
[[ $1 == '-b' ]] && LBD=true && shift					#get -b option if present

SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR
FULLPATH="$(readlink -e "$1")"
[[ -d $FULLPATH ]] || die Directory $FULLPATH does not exists
EXCUDELIST="$2"

MOUNT="$(stat -c %m "$FULLPATH")"
DIR="${FULLPATH#$MOUNT}"
DIR="${DIR#/}"

#DEV=$(df --output=source "$MOUNT"|tail -1)
#source "$SDIR/drive.sh" "$DEV" || die Cannot execute $SDIR/drive.sh $DEV
VOLUMESERIALNUMBER=$("$SDIR/drive.sh" "$FULLPATH" 2>/dev/null |cut -d'|' -f2)


CACHE="$SDIR/cache/hashes/by-volume/$VOLUMESERIALNUMBER/$DIR"
MARK="$CACHE/.lastrun"
WD="$SDIR/run"
NEW="$CACHE/new.csv"
DB="$CACHE/hashes.db"
exists cygpath && DB=$(cygpath -w "$DB")

[[ -n $LBD && -e $DB ]] && echo $DB && exit
[[ -n $LDB ]] && exit 1

mkdir -p "$CACHE"
mkdir -p "$WD"


EXC=$(
	[[ -n $EXCUDELIST ]] || EXCUDELIST="$SDIR/conf/excludes.txt"
	[[ -f $EXCUDELIST ]] && cat "$EXCUDELIST"|
	sed -E '/^#/d;/^\s*$/d;s/ /?/g'|
	sed -E "
		/^[^/]*$/{s%%-name '&'%p;d}
		/^([^/]*)[/]$/{s%%-name '\1' -type d%p;d}
		/^[/](.*[^/])$/{s%%-wholename './$DIR\1'%p;d}
		/^[/](.*)[/]$/{s%%-path './$DIR\1' -type d%p;d}
		/^(.*)[/]$/{s%%-path '\1' -type d%p;d}
		/^[*].*[*]$/{s%%-path '&'%p;d}
		/^[*].*[^*]$/{s%%-path '&/*'%p;d}
		/^[^*].*[*]$/{s%%-path '*/&'%p;d}
		s%.*/.*%-path '*&*'%
	"|
	sed 's/^\s*-.*$/& -prune -o/'|
	tr '\n' ' '
)

PREFIX=${DIR:+$DIR/}
FORMAT="${PREFIX}%P\0"

MTIME='01/01/1970'
[[ -s "$DB" && -s "$MARK" && -z $FULL ]] && {
	MTIME=$(cat $MARK)
	date -d "$MTIME" || MTIME='01/01/1970'
} >/dev/null 2>&1

date -R > "$MARK"

cd $MOUNT

sh -c "find './$DIR' -ignore_readdir_race -xdev $EXC -type f -newermt '$MTIME' -printf '$FORMAT'"|
xargs -r0 sha256sum -b|sed -E 's/\s+\*/|/'|
while IFS='|' read -r HASH FILE
do
	echo "$HASH|$(stat -c '%s|%Y' "$FILE")|$FILE"
done | sed -n '/^[^|]*[|][^|]*[|][^|]*[|][^|]*$/p'|tee "$NEW"

{
	exists cygpath && NEW=$(cygpath -w "$NEW")
	echo "DROP TABLE IF EXISTS TMP;"
	echo "CREATE TABLE TMP(hash TEXT, size INT, time INT,filename TEXT);"
	echo "CREATE TABLE IF NOT EXISTS H(hash TEXT, size INT, time INT,filename TEXT PRIMARY KEY);"
	echo '.separator "|"'
	echo ".import '$NEW' TMP"
	echo "INSERT OR REPLACE INTO H SELECT * FROM TMP;"
	echo "DROP TABLE IF EXISTS TMP;"
}|sqlite3 "$DB"



