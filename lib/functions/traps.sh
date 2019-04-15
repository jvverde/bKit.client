#!/usr/bin/env bash
#trap 'warn ${LINENO} $?' ERR
declare -p hdsddJHDKSDGHskDCSDhgdag > /dev/null 2>&1 && echo module trap already inserted && return
declare -r hdsddJHDKSDGHskDCSDhgdag=1

fn_exists() {
    declare -f -F "$1" > /dev/null
}

declare -a EXITFN=()

atexit() {
	for F in "$@"
	do
		fn_exists "$F" && declare FN="$F" && EXITFN+=( "$FN" )
	done
}

doexit() {
	CODE=$?
	trap '' EXIT
	set +eu
	for FN in "${EXITFN[@]}"
	do
		"$FN"
	done
	exit $CODE
}

trap doexit EXIT SIGINT SIGTERM
