#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR=$(cygpath "$(dirname "$(readlink -f "$0")")")	#Full DIR

[[ $1 == "-f" ]] && FORCE=true && shift

BACKUPDIR="$1"

die() { echo -e "$@"; exit 1; }

[[ $BACKUPDIR =~ ^[a-zA-Z]: ]]  || die "\nUsage:\n\t$0 [-u|-f] Drive:\\full-path-of-backup-dir"

BUDIR="$(cygpath "$BACKUPDIR")"

echo Check acls for $BACKUPDIR
[[ -d "$BUDIR" ]] || die "The directory $BACKUPDIR ($BUDIR)doesn't exist"

DRIVE=${BACKUPDIR%%:*}
DRIVE=${DRIVE^^}
BPATH=${BACKUPDIR#*:} #remove anything until character ':' inclusive
BPATH=${BPATH#*\\}    #remove anything until character '\' inclusive
BPATH=${BPATH%%\\}    #remove last, if exist, character '\'

. $SDIR/drive.sh
RID="$DRIVE.$VOLUMESERIALNUMBER.$VOLUMENAME.$DRIVETYPE.$FILESYSTEM/.bkit/"

ACLSDIR="$SDIR/cache/$RID/.acls"
FLAG="$ACLSDIR/.flag"
mkdir -p "$ACLSDIR" || die Cannot create dir $ACLSDIR

SUBINACL=$(find "$SDIR/3rd-party" -type f -name "subinacl.exe" -print | head -n 1)
[[ -f $SUBINACL ]] || die SUBINACL.exe not found

if [[ $FORCE || ! -f "$FLAG" || $(find "$FLAG" -mtime +7) ]]
then 
  echo Get acls of $BACKUPDIR
  find "$BUDIR" -path "*/.bkit/.acls/*" -prune -o -type d -printf "%P\n" | 
  while read DIR
  do
    SPATH="$(cygpath -w "$BUDIR/$DIR")"
    DPATH="$(cygpath -w "$ACLSDIR/$DIR")"
    mkdir -p "$DPATH" || continue
    $SUBINACL /noverbose /output="$DPATH\\acls" /file "$SPATH\*"
  done
  touch $FLAG
fi
echo ACLS done for $BACKUPDIR 