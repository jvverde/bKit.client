#!/usr/bin/env bash
#exec sudo "$0" "$@"
echo "call '$@'"
declare -a args=()
for arg in "$@"
do
  #echo arg1="'$arg'"
  [[ $arg =~ ^- ]] || arg="$(echo $arg|perl -lape 's/^"(.+)"$/$1/')" #This is a workaround to remove extra quotes introduced my cmd.exe
  #echo arg2="'$arg'"
  args+=( "$arg" )
done
exec ${@+"${args[@]}"}