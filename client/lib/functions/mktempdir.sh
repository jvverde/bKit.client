#!/usr/bin/env bash
declare -p _73a325646d49adc1f6b82af9b96cab7d >/dev/null 2>&1 && echo module mktempdir already inserted && return
declare -a _73a325646d49adc1f6b82af9b96cab7d=()


mktempdir() {
	declare -r tmpdir="$1"
	declare -r tmpname="$(mktemp -d --suffix=".bkit.$(basename --suffix=.sh -- "$0")")"
	declare -r dir="$(dirname -- "$(readlink -ne -- "${BASH_SOURCE[0]}")")"
	source "$dir/traps.sh"

	_73a325646d49adc1f6b82af9b96cab7d+=( "$tmpname" )

	eval "declare -rg $tmpdir='$tmpname'" 

	(( ${#_73a325646d49adc1f6b82af9b96cab7d[@]} == 1 )) && atexit rmtempdir
	return 0
}

rmtempdir(){
	rm -rf "${_73a325646d49adc1f6b82af9b96cab7d[@]}"
}

