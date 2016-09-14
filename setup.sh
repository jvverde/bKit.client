#!/bin/bash
[[ $UID -eq 0 ]] || exec sudo "$0" "$@"
SDIR="$(dirname "$(readlink -f "$0")")"               #Full DIR
apt-get update
apt-get install -y sqlite3

U=$(who am i | awk '{print $1}')
USERID=$(id -u $U)
GRPID=$(id -g $U)

for DIR in logs run cache
do
  [[ -d "$SDIR/$DIR" ]] || {
    mkdir -pv "$SDIR/$DIR" && chown -v $USERID:$GRPID "$SDIR/$DIR"
  }
done