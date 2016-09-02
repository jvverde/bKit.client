#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR=$(cygpath "$(dirname "$(readlink -f "$0")")")	#Full DIR

[[ $1 == '-f' ]] && FORCE=true && shift

BACKUPDIR="$1"

die() { echo -e "$@"; exit 1; }
doalarm(){ perl -e 'alarm shift; exec @ARGV' -- "$@";}



[[ $BACKUPDIR =~ ^[a-zA-Z]: ]]  || die "\nUsage:\n\t$0 [-u|-f] Drive:\\full-path-of-backup-dir"

BUDIR=$(cygpath "$BACKUPDIR")

echo Check acls for $BACKUPDIR
[[ -d "$BUDIR" ]] || die "The directory $BACKUPDIR ($BUDIR)doesn't exist"

DRIVE=${BACKUPDIR%%:*}
DRIVE=${DRIVE^^}
BPATH=${BACKUPDIR#*:} #remove anything until character ':' inclusive
BPATH=${BPATH#*\\}    #remove anything until character '\' inclusive
BPATH=${BPATH%%\\}    #remove last, if exist, character '\'

. $SDIR/drive.sh
RID="$DRIVE.$VOLUMESERIALNUMBER.$VOLUMENAME.$DRIVETYPE.$FILESYSTEM/.bkit/"

[[ $FILESYSTEM == 'NTFS' ]] || die Not a NTFS file system: $FILESYSTEM

ACLSDIR="$SDIR/cache/metadata/$RID/$BPATH"
mkdir -pv "$ACLSDIR" || die Cannot create dir $ACLSDIR

SUBINACL=$(find "$SDIR/3rd-party" -type f -name "subinacl.exe" -print | head -n 1)
[[ -f $SUBINACL ]] || die SUBINACL.exe not found

acldir(){
	WSPATH=$(cygpath -w "$1")
	WACLSFILE=$(cygpath -w "$2")	
	WSIDSFILE=$(cygpath -w "$3")
	$SUBINACL /noverbose /output="$WACLSFILE" /dumpcachedsids="WSIDSFILE" /file "$WSPATH"
}
aclfiles(){
	WSPATH=$(cygpath -w "$1")
	WACLSFILE=$(cygpath -w "$2")	
	WSIDSFILE=$(cygpath -w "$3")
	$SUBINACL /noverbose /output="$WACLSFILE" /dumpcachedsids="WSIDSFILE" /file "$WSPATH\\*"
}

THISFLAG="$ACLSDIR/.this.flag.f"

test -n "$(find "$THISFLAG" -mtime -1)" && echo "Is too soon to check it again" && exit 

SYSTEMUSERS="$ACLSDIR/.bkit.users.f"
doalarm 5 wmic useraccount get > "$SYSTEMUSERS"

THISACL="$ACLSDIR/.bkit.this.acls.f"

[[ -e $THISACL ]] || acldir "$BACKUPDIR" "$THISACL" "$ACLSDIR/.bkit.this.sids.f"

test -n "$(find "$BACKUPDIR" -maxdepth 0 -newercm "$THISACL" -print -quit)" && 
	acldir "$BACKUPDIR" "$THISACL" "$ACLSDIR/.bkit.this.sids.f"
	
find "$BUDIR" -path "$SDIR/cache/*" -prune -o -type d -printf "%P\n" | 
while read -r DIR
do
	SPATH="$BUDIR/$DIR"
	echo Check $SPATH
	DPATH="$ACLSDIR/$DIR"
	mkdir -pv "$DPATH" || continue
	ACLSFILE="$DPATH/.bkit.acls.f"
	[[ -e "$ACLSFILE" ]] || aclfiles "$SPATH" "$ACLSFILE" "$DPATH/.bkit.this.sids.f"
	test -n "$(find "$SPATH" -maxdepth 1 -mindepth 1 -newercm "$ACLSFILE" -print -quit)" &&
		aclfiles "$SPATH" "$ACLSFILE" "$DPATH/.bkit.this.sids.f"
done

touch "$THISFLAG"
echo ACLS done for $BACKUPDIR 
