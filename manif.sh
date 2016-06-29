#!/bin/bash
for VOL in $(ls /cygdrive)
do
  find /cygdrive/$VOL -not -empty -type f -printf "%H|/%P\n"
done
exit