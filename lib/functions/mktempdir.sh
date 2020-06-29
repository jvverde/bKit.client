#!/usr/bin/env bash
declare -p _9e0f1d5a15e465a168ca0956a4c3b98a >/dev/null 2>&1 && return
declare -a _9e0f1d5a15e465a168ca0956a4c3b98a=()

declare -f -F atexit >/dev/null || source "$(dirname -- "$(readlink -ne -- "${BASH_SOURCE[0]}")")/traps.sh"

mktempdir() {
	declare -r tmpdir="$1"
	declare -r tmpname="$(mktemp -d --suffix=".bkit.$(basename --suffix=.sh -- "$0")")"

	_9e0f1d5a15e465a168ca0956a4c3b98a+=( "$tmpname" )

	eval "declare -rg $tmpdir='$tmpname'" 

	(( ${#_9e0f1d5a15e465a168ca0956a4c3b98a[@]} == 1 )) && atexit rmtempdir
	return 0
}

rmtempdir(){
  #rm -rf "${_9e0f1d5a15e465a168ca0956a4c3b98a[@]}"
  #We should be very carefull with "rm -rf" command 
  find "${_9e0f1d5a15e465a168ca0956a4c3b98a[@]}" -maxdepth 0 -type d -name 'tmp.*.bkit.*' -print0 | xargs -r0I{} rm -rf "{}" ';'

  # delete also any bkit temporary file older than 30 days
  declare -r parent="$(dirname -- "$(mktemp -u)")"
  find "$parent" -path '*/tmp.*.bkit.*' -mtime +30 -delete 2>/dev/null
}
