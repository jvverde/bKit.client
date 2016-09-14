#!/bin/bash
SDIR="$(dirname "$(readlink -f "$0")")"       #Full DIR
apt-get update
apt-get install -y sqlite3

DIRS=(logs run cache)
for DIR in $DIRS
do
  [[ -d "$SDIR/$DIR" ]] || mkdir -pv "$SDIR/$DIR"
done