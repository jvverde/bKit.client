#!/usr/bin/env bash
#List differences between local and backup
set -u
sdir="$(dirname -- "$(readlink -ne -- "$0")")"
source "$sdir/lib/functions/all.sh"

usage() {
	local NAME=$(basename -s .sh "$0")
	echo Show differences to last backup
	echo -e "Usage:\n\t $NAME dir1/file1 [[dir2/file2 [...]]"
	exit 1
}

[[ $# -eq 0 ]] && usage

declare -a filters=( --filter=": .rsync-filter" )

exclist=$sdir/cache/$USER/excludes/exclude.lst
[[ -e $exclist ]] && filters+=( --filter=". $exclist" )

while IFS='|' read i datetime size file
do
	exists cygpath && file=$(cygpath -w "$file")
	echo "$i|$datetime|$size|$file"
done < <(bash "$sdir/check.sh" --snap="@last" --out-format="%i|%M|%l|/%f"  "${filters[@]}" "$@")
