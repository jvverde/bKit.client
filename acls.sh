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

ACLSDIR="$SDIR/cache/$RID/$BPATH"
mkdir -pv "$ACLSDIR" || die Cannot create dir $ACLSDIR

SUBINACL=$(find "$SDIR/3rd-party" -type f -name "subinacl.exe" -print | head -n 1)
[[ -f $SUBINACL ]] || die SUBINACL.exe not found

[[ -e "$ACLSDIR/.bkit.users.f" ]] || doalarm 5 wmic useraccount get > "$ACLSDIR/.bkit.users.f"

[[ -e "$ACLSDIR/.bkit.this.acls.f" ]] || (
	WACLDIR=$(cygpath -w "$ACLSDIR/")
	$SUBINACL /noverbose /output="${WACLDIR}\\.bkit.this.acls.f" /dumpcachedsids="${WACLDIR}\\.bkit.this.sids.f" /file "$BACKUPDIR"
)

find "$BUDIR" -path "$SDIR/cache/*" -prune -o -type d -printf "%P\n" | 
while read -r DIR
do
	SPATH="$BUDIR/$DIR"
	DPATH="$ACLSDIR/$DIR"
	mkdir -pv "$DPATH" || continue
	ACLSFILE="$DPATH/.bkit.acls.f"
	WSPATH=$(cygpath -w "$SPATH")
	WSIDSFILE=$(cygpath -w "$DPATH/.bkit.sids.f")
	WACLSFILE=$(cygpath -w "$ACLSFILE")
	[[ -e "$ACLSFILE" ]] || $SUBINACL /noverbose /output="$WACLSFILE" /dumpcachedsids="$WSIDSFILE" /file "$WSPATH\*"
	NEW=($(find "$SPATH" -maxdepth 1 -mindepth 1 -newercm "$ACLSFILE" -print -quit))
	((${#NEW[@]} > 0 )) && $SUBINACL /noverbose /output="$WACLSFILE" /dumpcachedsids="$WSIDSFILE" /file "$WSPATH\*"
done
echo ACLS done for $BACKUPDIR 
