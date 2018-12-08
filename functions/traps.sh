#!/usr/bin/env bash
#trap 'warn ${LINENO} $?' ERR

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
	for FN in "${EXITFN[@]}"
	do
		"$FN"
	done
	exit $CODE
}

trap doexit EXIT SIGINT SIGTERM
