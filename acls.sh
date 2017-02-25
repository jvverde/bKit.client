#!/bin/bash
die() { echo -e "$@">&2; exit 1; }
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH

type cygpath >/dev/null 2>&1 || die Cannot found cygpath

SDIR=$(cygpath "$(dirname "$(readlink -f "$0")")")	#Full DIR

[[ $1 == '-f' ]] && FORCE=true && shift


STARTDIR=$(cygpath "$1")
ACLSDIR=$(cygpath "$2")
ACLSDIR=${ACLSDIR%/}

[[ -d $STARTDIR ]]  || die "\nUsage:\n\t$0 [-u|-f] BackupDir DestinationDir"
[[ -n $ACLSDIR ]] || die "\nUsage:\n\t$0 [-u|-f] BackupDir DestinationDir"

echo Check acls for $STARTDIR

mkdir -pv "$ACLSDIR" || die Cannot create dir $ACLSDIR

SUBINACL=$(find "$SDIR/3rd-party" -type f -name "subinacl.exe" -print -quit)
[[ -f $SUBINACL ]] || die SUBINACL.exe not found

acldir(){
	local WSPATH=$(cygpath -w "$1")
	local WACLSFILE=$(cygpath -w "$2")
	local WSIDSFILE=$(cygpath -w "$3")
	"$SUBINACL" /noverbose /output="$WACLSFILE" /dumpcachedsids="$WSIDSFILE" /file "$WSPATH"
}
aclfiles(){
	local WSPATH=$(cygpath -w "$1")
	local WACLSFILE=$(cygpath -w "$2")
	local WSIDSFILE=$(cygpath -w "$3")
	"$SUBINACL" /noverbose /output="$WACLSFILE" /dumpcachedsids="$WSIDSFILE" /file "$WSPATH\\*"
}

THISFLAG="$ACLSDIR/.this.flag.f"

[[ -z $FORCE && -e "$THISFLAG" && -n "$(find "$THISFLAG" -mtime -1)" ]] && echo "Is too soon to check it again" && exit

SYSTEMUSERS="$ACLSDIR/.bkit.users.f"
timeout -k 1m 1m wmic useraccount get > "$SYSTEMUSERS"

THISACL="$ACLSDIR/.bkit.this.acls.f"

[[ ! -e $THISACL || -n "$(find "$STARTDIR" -maxdepth 0 -newercm "$THISACL" -print -quit)" ]] &&
	acldir "$STARTDIR" "$THISACL" "$ACLSDIR/.bkit.this.sids.f"

EXCDIR1="*/${ACLSDIR#/cygdrive/?/}"
EXCDIR2="*/${SDIR#/cygdrive/?/}"
find "$STARTDIR" -path "$EXCDIR1" -prune -o -path "$EXCDIR2" -prune -o -name '.bkit' -prune -o -type d -printf "%P\n" |
while read -r DIR
do
	SPATH="$STARTDIR/$DIR"
	DPATH="$ACLSDIR/$DIR"
	[[ -d "$DPATH" ]] || mkdir -pv "$DPATH" || continue
	ACLSFILE="$DPATH/.bkit.acls.f"
	THISACL="$DPATH/.bkit.this.acls.f"
	#if aclfile doen't exists or is older than a file in directory
	[[ ! -e "$ACLSFILE" || -n "$(find "$SPATH" -maxdepth 1 -mindepth 1 -newercm "$ACLSFILE" -print -quit)" ]] &&
		aclfiles "$SPATH" "$ACLSFILE" "$DPATH/.bkit.sids.f"
	[[ ! -e "$THISACL" || -n "$(find "$SPATH" -maxdepth 1 -mindepth 1 -newercm "$THISACL" -print -quit)" ]] &&
		aclfiles "$SPATH" "$THISACL" "$DPATH/.bkit.this.sids.f"
done

touch "$THISFLAG"
echo ACLS done for $STARTDIR
