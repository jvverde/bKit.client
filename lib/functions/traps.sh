#!/usr/bin/env bash
#trap 'warn ${LINENO} $?' ERR
declare -p _665dff8f985f6292ab5d18cc36b2db1e > /dev/null 2>&1 && return
declare -r _665dff8f985f6292ab5d18cc36b2db1e=1

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
