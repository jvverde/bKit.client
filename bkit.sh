#!/usr/bin/env bash
set -uE
sdir="$(dirname -- "$(readlink -ne -- "$0")")"        #Full DIR
source "$sdir/lib/functions/all.sh"

declare -a filters=()

declare -r exclist="$VARDIR/excludes/excludes.lst"
declare exclist2show="$exclist"
exists cygpath && exclist2show="$(cygpath -w "$exclist2show")"

excludes(){
  [[ -e "$exclist" ]] || {
    echo Compile exclude list
    mkdir -pv "${exclist%/*}"
    bash "$sdir/lib/tools/excludes.sh" "$sdir/excludes" |sed -E 's/ +$//' >  "$exclist"
  }
  [[ -n $(find "$exclist" -mtime +30) || ${compile+isset} == isset ]] && {
    echo Recompile exclude list
    bash "$sdir/lib/tools/excludes.sh" "$sdir/excludes" |sed -E 's/ +$//' >  "$exclist"
  }

  filters+=( --filter=". $exclist" )
}

usage() {
    #local name=$(basename -s .sh -- "$0")
    local name=$(basename -- "$0")
    echo Backup one or more directories or files using excluding list and using rsync rules
    cat <<EOM
Usage: $name [OPTIONS] [-- RSYNCOPTIONS] [dir1/file1 [[dir2/file2 [...]]]

Options:
  -a, --all              Backup all. Ignore exclude list in '$exclist2show' 
  -c, --compile          (Re)compile a exclude list of files in '$exclist2show'
  --ignore-filters       Ignore filters defined in .rsync-filter and in .bkit-filter files
  --no-inherit-filters   Do not inherit filters from parent dirs
  -h, --help             Display this help message
  --stats                Enable statistics
  --sendlogs             Send logs
  --notify               Enable notifications
  --filter FILTER        Apply FILTER
  Plus any option accepted by 'backup.sh' see "$sdir/backup.sh --help" 

RsyncOptions:
	Any option supported by rsync


Example:
  $0                              #Backup current dir
  $0 dirname                      #Backup 'dirname' but exclude files in '$exclist2show' and use the rules in .rsync-filter or .bkit-filter found in the path(s)
  $0 -a --no-filters dirname      #Backup everything under 'dirname'
  $0 --no-inherit-filters dirname #Backup ignoring the rules on .rsync-filter or .bkit-filter found on any parent/ancestor of 'dirname'
  $0 --no-ssh                     #Backup without using SSH

EOM
    exit 1
}

declare -a options=() rsyncoptions=()

while [[ ${1:-} =~ ^- ]]
do
  key="$1" && shift
  case "$key" in
    -- )
      while [[ ${1:-} =~ ^- ]]
      do
        rsyncoptions+=( "$1" )
        shift
      done
    ;;
    -a|--all)
      all=1
    ;;
    -c|--compile)
      compile=1
    ;;
    --ignore-filters)
      nofilters=1
    ;;
    --no-inherit-filters)
      noinheritfilters=1
    ;;
    -h|--help)
      usage
    ;;
    --stats|--sendlogs|--notify)
      options+=( "$key")
    ;;
    --filter)
      options+=( "--filter '$1'")
      shift
    ;;
    *)
      options+=( "$key")
    ;;
  esac
done

#(( $# == 0 )) && usage

[[ ${all+isset} == isset ]] || excludes

[[ ${nofilters+isset} == isset ]] || { # Unlees nofilters is set, include filters bellow
  if [[ ${noinheritfilters+isset} == isset ]]
  then 
    filters+=( --filter=":n- .rsync-filter")
    filters+=( --filter=":n- .bkit-filter")
  else
    filters+=( --filter=": .rsync-filter" )
    filters+=( --filter=": .bkit-filter" )
  fi
}


declare -r pgid="$(cat /proc/self/pgid 2>/dev/null)"
echo "bKit[$$:$pgid]: Start backup for ${@:-.}"
let cnt=16
let sec=60
while (( cnt-- > 0 ))
do
  bash "$sdir/backup.sh" ${options+"${options[@]}"} -- ${filters+"${filters[@]}"} ${rsyncoptions+"${rsyncoptions[@]}"} "${@:-.}" && break
  let delay=(1 + RANDOM % $sec)
  echo "bKit:Wait $delay seconds before try again"
  sleep $delay
  let sec=2*sec
done
echo "bKit[$$:$pgid]: Done"
