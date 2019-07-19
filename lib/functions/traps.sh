#!/usr/bin/env bash
#trap 'warn ${LINENO} $?' ERR
declare -p _b7b54a88cbf32e938888d99b60da96d5 > /dev/null 2>&1 && echo module traps already inserted && return
declare -r _b7b54a88cbf32e938888d99b60da96d5=1

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
