#!/bin/bash
SDIR=$(dirname "$(readlink -f "$0")")	#Full DIR
BACKUPDIR="$1"

DRIVE=${BACKUPDIR%%:*}

SSPAWN=$(find $SDIR -type f -name "ShadowSpawn.exe" -print | head -n 1)
[[ -f $SSPAWN ]] || die "ShadowSpawn.exe not found"

BASH="$(cygpath -w "$SDIR/bash.bat")"
BACKUP="$(cygpath -w "$SDIR/backup.sh")" 
$SSPAWN "$DRIVE:\\" B: $BASH $BACKUP $BACKUPDIR B: