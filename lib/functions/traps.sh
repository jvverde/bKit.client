#!/usr/bin/env bash
#Set traps for exit sigint and sigterm
#trap 'warn ${LINENO} $?' ERR

#Declare an array of function if not yet decalred
declare -p _bkit_EXITFN >/dev/null 2>&1 || declare -a _bkit_EXITFN=()

_bkit_fn_exists() {
  declare -f -F "$1" > /dev/null
}

_bkit_doexit() {
	declare -r code=$?
	trap '' EXIT
	set +eu
	for FN in "${_bkit_EXITFN[@]}"
	do
		"$FN"
	done
	exit $code
}

_bkit_set_traps() {
	trap _bkit_doexit EXIT SIGINT SIGTERM
}

atexit() {
	for F in "$@"
	do
		_bkit_fn_exists "$F" && declare FN="$F" && _bkit_EXITFN+=( "$FN" )
	done
}

_bkit_set_traps
