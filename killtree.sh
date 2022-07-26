#!/usr/bin/env bash
#exec sudo "$0" "$@"
#I should read (again this https://stackoverflow.com/questions/1679337/convert-a-cygwin-pid-to-a-windows-pid)
set -u

die() {
  echo -e "$@"
  exit 1
}

[[ ${1+isset} == isset ]] || die "Usage:\n\t$0 pid"

if ps -p "$1" > /dev/null
then
  OS="$(uname -o |tr '[:upper:]' '[:lower:]')"
  if [[ $OS == cygwin ]]
  then
    pgfile="/proc/$1/pgid"
    [[ -e $pgfile ]] || die "Can't find '$pgfile' file"
    pgid="-$(cat "$pgfile")"
  else
    pgid="-$(ps -h -o pgid -p "$1")"
  fi 
  kill -- "$pgid" 
else
  echo "No process '$1' to kill"
fi