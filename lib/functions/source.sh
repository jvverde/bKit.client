#!/usr/bin/env bash
declare -F _bkit_use > /dev/null 2>&1 && [[ ! ${1+$1} =~ ^-f ]] && return

_bkit_use(){
	declare -r myself="$(readlink -ne -- "${BASH_SOURCE[0]}")"

	declare -r dir="$(dirname -- "$myself")"

  for arg in "$@"
  do
    source "$dir/${arg%.sh}.sh"
  done    
}

${__SOURCED__:+return} #Intended for shellspec tests

_bkit_use "$@"

if [[ ${BASH_SOURCE[0]} == "$0" ]]
then
  echo "The script '$0' is meant to be sourced"
  echo "Usage: source '$0'"
fi
