#!/usr/bin/env bash
declare -p _f6eda119529f67874f7dae8b73cdb799 > /dev/null 2>&1 && return
declare -r _f6eda119529f67874f7dae8b73cdb799=1

_f6eda119529f67874f7dae8b73cdb799(){

	declare -r myself="$(readlink -ne -- "${BASH_SOURCE[0]}")"

	declare -r dir="$(dirname -- "$myself")"

	#source <(find "$dir" -maxdepth 1 -type f -name '*.sh' ! -path "$myself" -exec cat "{}" ';')
	while IFS= read file
	do
		source "$file"
	done < <( find "$dir" -maxdepth 1 -type f -name '*.sh' ! -path "$myself" )

  true ${USER:="$(id -un)"}
}

_f6eda119529f67874f7dae8b73cdb799