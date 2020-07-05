#!/usr/bin/env bash
declare -p _d9a6afe59c48aaccbbc36e5e346cec49 > /dev/null 2>&1 && return
declare -r _d9a6afe59c48aaccbbc36e5e346cec49=1

_d9a6afe59c48aaccbbc36e5e346cec49(){

	declare -r myself="$(readlink -ne -- "${BASH_SOURCE[0]}")"

	declare -r dir="$(dirname -- "$myself")"

	#source <(find "$dir" -maxdepth 1 -type f -name '*.sh' ! -path "$myself" -exec cat "{}" ';')
	while IFS= read -r -d $'\0' file
	do
		source "$file"
	done < <(find "$dir" -maxdepth 1 -type f -name '*.sh' ! -path "$myself" -print0)
  true ${BKITUSER:="$(id -un)"}
}

_d9a6afe59c48aaccbbc36e5e346cec49
