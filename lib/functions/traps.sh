#!/usr/bin/env bash
#trap 'warn ${LINENO} $?' ERR
declare -p _8b4c9249d1bf474b4ac7f84329135abd > /dev/null 2>&1 && return
declare -r _8b4c9249d1bf474b4ac7f84329135abd=1

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
