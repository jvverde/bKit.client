#!/usr/bin/env bash
declare -p FRGUFRYFAGFADFWYLFGQYFRQVRFQWRF >/dev/null 2>&1 && echo module mktempdir already inserted && return

declare -a FRGUFRYFAGFADFWYLFGQYFRQVRFQWRF=()
mktempdir() {
	local EPIUWETGPQWEGRFQFLAFHKASVLFGQLGFLQ="$1"
        local TMP="$(mktemp -d --suffix=".bkit.$(basename --suffix=.sh -- "$0")")"
        FRGUFRYFAGFADFWYLFGQYFRQVRFQWRF+=( "$TMP" )
	eval $EPIUWETGPQWEGRFQFLAFHKASVLFGQLGFLQ="'$TMP'" 
	(( ${#FRGUFRYFAGFADFWYLFGQYFRQVRFQWRF[@]} == 1 )) && atexit rmtempdir
	return 0
}

rmtempdir(){
        rm -rf "${FRGUFRYFAGFADFWYLFGQYFRQVRFQWRF[@]}"
}

