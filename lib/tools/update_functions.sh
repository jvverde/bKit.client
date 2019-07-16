#!/usr/bin/env bash
sdir=$(dirname -- "$(readlink -ne -- "$0")")	#Full SDIR

find "$sdir/../functions" -type f -print0|
  xargs -r0I{} md5sum "{}" |
    while read -r hash file
    do
      echo $hash
      echo $file
      match=$(grep -Pio '(?<=declare -p )[a-z]{10,}(?= >)' "$file") || continue
      echo match=$match
      sed "s#$match#$hash#" "$file"
    done
