#!/usr/bin/env bash
#update hashed strings7variables names on each function
sdir=$(dirname -- "$(readlink -ne -- "$0")")	#Full SDIR
sdir="${sdir%/lib*}"  #assuming we are inside a lib directory under client area

find "$sdir/lib/functions" -type f -print0|
  xargs -r0I{} grep -PioH '(?<=declare -p _)[a-f0-9]{32}(?= ?>)' "{}" |
    while IFS=':' read -r file match
    do
      #compute new hash but without old hash 
      hash="$(sed "s#$match##" "$file" | md5sum | awk '{print $1}')"     
      [[ $match == $hash ]] || sed -i "s#$match#$hash#" "$file"
    done
