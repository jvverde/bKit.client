#!/usr/bin/env bash
declare -p _f7665047f18a8d740ce732d4ce578608 >/dev/null 2>&1 && echo module mktempdir already inserted && return
declare -a _f7665047f18a8d740ce732d4ce578608=()


mktempdir() {
	local tmpdir="$1"
	local tmpname="$(mktemp -d --suffix=".bkit.$(basename --suffix=.sh -- "$0")")"
	local sdir="$(dirname -- "$(readlink -ne -- "${BASH_SOURCE[0]}")")"
	
	source "$sdir/traps.sh"

	_f7665047f18a8d740ce732d4ce578608+=( "$tmpname" )

	eval $tmpdir="'$tmpname'" 

	(( ${#_f7665047f18a8d740ce732d4ce578608[@]} == 1 )) && atexit rmtempdir
	return 0
}

rmtempdir(){
	rm -rf "${_f7665047f18a8d740ce732d4ce578608[@]}"
}

