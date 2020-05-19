#!/usr/bin/env bash
#exec sudo "$0" "$@"
#echo "call '$@'"
declare -a args=()
for arg in "$@"
do
  [[ $arg =~ ^- ]] || arg="$(echo $arg|perl -lape 's/^"(.+)"$/$1/')" #This is a workaround to remove extra quotes introduced my cmd.exe
  args+=( "$arg" )
done
exec ${@+"${args[@]}"}