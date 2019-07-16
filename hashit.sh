#!/usr/bin/env bash
#compute hash values for missing files on bkit server
#output on form a/b/c/d/e/f/[0-9a-f]{58}|size|time|relative path on server side
#:ex: 1/3/2/0/2/5/750401dd51cd5ba7a44dd7adcb9d4fc7f2e59df4bacf39c7da178868a3|180|1543680565|bkit/scripts/client/conf/tmp/sshkey.pub
set -u
sdir=$(dirname -- "$(readlink -en -- "$0")")	#Full sdir

source "$sdir/lib/functions/all.sh"

declare -a options=()
while [[ $1 =~ ^- ]]
do
  key="$1" && shift
  case "$key" in
  *)
    options+=( "$key" ) 
  ;;
  esac
done

(( $# == 0 )) && die "Usage:\n\t$0 dirs" 

for dir in "$@"
do
	fullpath="$(readlink -e -- "$dir")" || continue

	root="$(stat -c %m "$fullpath")"

	bash "$sdir/check.sh" ${options+"${options[@]}"} --out-format='%i|/%f' "$fullpath"|
		awk 'BEGIN {FS="|";ORS="\0"} $1 ~ /^<f/ {print $2}' | #filter out only files who needs update (<f). Ignore all the other situations
			xargs -r0I{} sha256sum -b "{}"|sed -E 's/\s+\*/|/' |
				while IFS='|' read -r hash file
				do
					rfile=${file#$root}  	#remove mounting point (root could be just a slash, so don't try to remove "$root/")
					rfile=${rfile#/} 	    #remove any leading slash if any
					echo "$hash|$(stat -c '%s|%Y' "$file")|$rfile"
				done | sed -rn 's#^(.)(.)(.)(.)(.)(.)#\1/\2/\3/\4/\5/\6/#p'
done
