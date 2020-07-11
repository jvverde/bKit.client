#!/usr/bin/env bash
declare -F _bkit_source_all > /dev/null 2>&1 && [[ ! ${1+$1} =~ ^-f ]] && return

_bkit_source_all(){
	declare -r myself="$(readlink -ne -- "${BASH_SOURCE[0]}")"

	declare -r dir="$(dirname -- "$myself")"

	while IFS= read -r -d $'\0' file
	do
    source "$file"
	done < <(find "$dir" -maxdepth 1 -type f -name '*.sh' ! -path "$myself" -print0)
}

${__SOURCED__:+return} #Intended for shellspec tests

_bkit_source_all

if [[ ${BASH_SOURCE[0]} == "$0" ]]
then
  echo "The script '$0' is meant to be sourced"
  echo "Usage: source '$0'"
fi
