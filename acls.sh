#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR=$(cygpath "$(dirname "$(readlink -f "$0")")")	#Full DIR

[[ $1 == '-f' ]] && FORCE=true && shift

BACKUPDIR="$1"

die() { echo -e "$@"; exit 1; }
doalarm(){ perl -e 'alarm shift; exec @ARGV' -- "$@";}



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


ACLSDIR="$SDIR/cache/$RID/.bkit.acls.d"
FLAGFILE="$ACLSDIR/$BPATH/.bkit.flag.f"
mkdir -p "$ACLSDIR" || die Cannot create dir $ACLSDIR

SUBINACL=$(find "$SDIR/3rd-party" -type f -name "subinacl.exe" -print | head -n 1)
[[ -f $SUBINACL ]] || die SUBINACL.exe not found
if [[ $FORCE || ! -f "$FLAGFILE" || $(find "$FLAGFILE" -mtime +1) ]]
then 
  echo Get acls of $BACKUPDIR
  WACLDIR="$(cygpath -w "$ACLSDIR/$BPATH/")"
  $SUBINACL /noverbose /output="${WACLDIR}.bkit.this.acls.f" /dumpcachedsids="${WACLDIR}.bkit.this.sids.f" /file "$BACKUPDIR"
  doalarm 5 wmic useraccount get > $ACLSDIR/$BPATH/.bkit.users.file
  find "$BUDIR" -path "*/.bkit/.bkit.acls.d/*" -prune -o -type d -printf "%P\n" | 
  while read DIR
  do
    SPATH="$(cygpath -w "$BUDIR/$DIR")"
    DPATH="$(cygpath -w "$ACLSDIR/$DIR")"
    mkdir -p "$DPATH" || continue
    $SUBINACL /noverbose /output="$DPATH\\.bkit.acls.f" /dumpcachedsids="$DPATH\\.bkit.sids.f" /file $SPATH\*
  done
  touch $FLAGFILE
  echo ACLS done for $BACKUPDIR 
else
  echo "$BACKUPDIR doesn't need compute ACLs this time"
fi
