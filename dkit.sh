#!/usr/bin/env bash
#List differences between local and last backup
set -u
sdir="$(dirname -- "$(readlink -ne -- "$0")")"
source "$sdir/lib/functions/all.sh"

usage() {
	local NAME=$(basename -s .sh "$0")
	echo Show differences to last backup
	echo -e "Usage:\n\t $NAME dir1/file1 [[dir2/file2 [...]]"
	exit 1
}

set_server () {
  source "$sdir"/server.sh "$1"
}

declare -a options=()
while [[ ${1:-} =~ ^- ]]
do
  key="$1" && shift
  case "$key" in
    -s|--server)
      set_server "$1" && shift
    ;;
    -s=*|--server=*)
      set_server "${key#*=}"
    ;;
    --?h*)
      usage
    ;;
    *)
      options+=( "$key" )
    ;;
  esac
done

if exists cygpath
then
  declare -a args=()
  for arg in "${@:-.}"
  do
    args+=( "$(cygpath -u "$arg")" )
  done
else
  declare -ra args=("${@:-.}")
fi

declare -a filters=( --filter=": .rsync-filter" )

exclist="$VARDIR/excludes/excludes.lst"

[[ -e $exclist ]] && filters+=( --filter=". $exclist" )

while IFS='|' read i datetime size file
do
	exists cygpath && file=$(cygpath -w "$file")
	echo "$i|$datetime|$size|$file"
done < <(bash "$sdir/check.sh" --snap="@last" ${options+"${options[@]}"} --out-format="%i|%M|%l|/%f"  "${filters[@]}" "${args[@]}")
