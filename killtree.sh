#!/usr/bin/env bash
#exec sudo "$0" "$@"
#I should read (again this https://stackoverflow.com/questions/1679337/convert-a-cygwin-pid-to-a-windows-pid)
set -u

die() {
  echo -e "$@"
  exit 1
}

[[ ${1+isset} == isset ]] || die "Usage:\n\t$0 pid"

if [[ ${1:-} =~ ^- ]]
then
  pgid="$1"
else  
  pgfile="/proc/$1/pgid"
  [[ -e $pgfile ]] || die "Can't find '$pgfile' file"
  pgid="-$(cat "$pgfile")"
fi

kill -- "$pgid" 
