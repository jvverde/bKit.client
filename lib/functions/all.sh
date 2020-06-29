#!/usr/bin/env bash
declare -p _8df9b4408cdf9837e37cd988b7d0a6f2 > /dev/null 2>&1 && return
declare -r _8df9b4408cdf9837e37cd988b7d0a6f2=1

_8df9b4408cdf9837e37cd988b7d0a6f2(){

	declare -r myself="$(readlink -ne -- "${BASH_SOURCE[0]}")"

	declare -r dir="$(dirname -- "$myself")"

	#source <(find "$dir" -maxdepth 1 -type f -name '*.sh' ! -path "$myself" -exec cat "{}" ';')
	while IFS=$'\n' read -r file
	do
		source "$file"
	done < <( find "$dir" -maxdepth 1 -type f -name '*.sh' ! -path "$myself" -print0)
  true ${BKITUSER:="$(id -un)"}
}

_8df9b4408cdf9837e37cd988b7d0a6f2
