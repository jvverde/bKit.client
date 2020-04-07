#!/usr/bin/env bash
#exec sudo "$0" "$@"
die() {
  echo -e "$@"
  exit 1
}

[[ ${1+isset} == isset ]] || die "Usage:\n\t$0 pid"

pgid="/proc/$1/pgid"

[[ -e $pgid ]] || die "Can't find '$pgid' file"

kill -- "-$(cat "$pgid")" 
