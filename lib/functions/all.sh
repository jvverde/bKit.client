#!/usr/bin/env bash
declare -p _bd543783f4067de2309b8f02b63d3417 > /dev/null 2>&1 && return
declare -r _bd543783f4067de2309b8f02b63d3417=1

_bd543783f4067de2309b8f02b63d3417(){

	declare -r myself="$(readlink -ne -- "${BASH_SOURCE[0]}")"

	declare -r dir="$(dirname -- "$myself")"

	#source <(find "$dir" -maxdepth 1 -type f -name '*.sh' ! -path "$myself" -exec cat "{}" ';')
	while IFS= read file
	do
		source "$file"
	done < <( find "$dir" -maxdepth 1 -type f -name '*.sh' ! -path "$myself" )
  true ${BKITUSER:="$(id -un)"}
}

_bd543783f4067de2309b8f02b63d3417