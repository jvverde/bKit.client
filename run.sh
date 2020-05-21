#!/usr/bin/env bash
declare -r sdir="$(dirname -- "$(readlink -ne -- "$0")")"
export PATH=".:$sdir:$PATH"
declare -a args=()
for arg in "$@"
do
  [[ $arg =~ ^- ]] || arg="$(echo $arg|perl -lape 's/^"(.+)"$/$1/')" #This is a workaround to remove extra quotes introduced my cmd.exe
  args+=( "$arg" )
done
exec ${@+"${args[@]}"}