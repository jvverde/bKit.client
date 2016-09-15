#!/bin/bash
DIR=$1

SDIR="$(dirname "$(readlink -f "$0/..")")"       #Full DIR
RUNDIR="$SDIR/run/dry-run.$$/"
[[ -d $RUNDIR ]] || mkdir -p "$RUNDIR"

FMT='--out-format=%f|%i'
EXC="--exclude-from=$SDIR/conf/excludes.txt"

trap "rm -rf $RUNDIR" EXIT

rsync --dry-run --recursive --relative --links --one-file-system --itemize-changes --size-only $EXC $FMT "$DIR" "$RUNDIR" |
  fgrep -a '|>f+++'|cut -d'|' -f1
