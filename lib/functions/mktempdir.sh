#!/usr/bin/env bash
declare -p _73a325646d49adc1f6b82af9b96cab7d >/dev/null 2>&1 && return
declare -a _73a325646d49adc1f6b82af9b96cab7d=()

declare -f -F atexit >/dev/null || source "$(dirname -- "$(readlink -ne -- "${BASH_SOURCE[0]}")")/traps.sh"

mktempdir() {
	declare -r tmpdir="$1"
	declare -r tmpname="$(mktemp -d --suffix=".bkit.$(basename --suffix=.sh -- "$0")")"

	_73a325646d49adc1f6b82af9b96cab7d+=( "$tmpname" )

	eval "declare -rg $tmpdir='$tmpname'" 

	(( ${#_73a325646d49adc1f6b82af9b96cab7d[@]} == 1 )) && atexit rmtempdir
	return 0
}

rmtempdir(){
  #rm -rf "${_73a325646d49adc1f6b82af9b96cab7d[@]}"
  #We should be very carefull with "rm -rf" command 
  find "${_73a325646d49adc1f6b82af9b96cab7d[@]}" -maxdepth 0 -type d -name 'tmp.*.bkit.*' -print0 | xargs -r0I{} rm -rf "{}" ';'

  # delete also any bkit temporary file older than 30 days
  declare -r parent="$(dirname -- "$(mktemp -u)")"
  find "$parent" -path '*/tmp.*.bkit.*' -mtime +30 -delete 2>/dev/null
}
