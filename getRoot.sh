#!/usr/bin/env bash
SDIR="$(dirname -- "$(readlink -ne -- "$0")")"				#Full DIR
source "$SDIR/lib/functions/all.sh"

[[ $1 == '-log' ]] && shift && exec 1>"$1" && shift

[[ -n $1 ]] || die "Usage:\n\t$0 path[ path[ path [...]]]"

for DIR in "$@"
do
  [[ -e $DIR ]] || die Cannot find $1

  FULLDIR=$DIR
  exists cygpath && FULLDIR=$(cygpath "$FULLDIR")

  FULLDIR=$(readlink -ne "$FULLDIR")

  MOUNT=$(stat -c%m "$FULLDIR")
  exists cygpath && {
    FULLDIR=$(cygpath -wl "$FULLDIR")
    MOUNT=$(cygpath -wl "$MOUNT")
  }
  echo "$DIR|$FULLDIR|$MOUNT"
done
