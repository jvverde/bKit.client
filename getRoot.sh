#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR
[[ $1 == '-log' ]] && shift && exec 1>"$1" && shift

exists() { type "$1" >/dev/null 2>&1;}
die() { echo -e "$@">&2; exit 1; }

[[ -n $1 ]] || die "Usage:\n\t$0 path[ path[ path [...]]]"
for DIR in "$@"
do
  [[ -e $DIR ]] || die Cannot find $1

  BDIR=$DIR
  exists cygpath && BDIR=$(cygpath "$BDIR")

  BDIR=$(readlink -ne "$BDIR")

  MOUNT=$(stat -c%m "$BDIR")
  exists cygpath && {
    BDIR=$(cygpath -w "$BDIR")
    MOUNT=$(cygpath -w "$MOUNT")
  }
  echo -e "$DIR\t$BDIR\t$MOUNT"
done
