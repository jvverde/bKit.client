#!/usr/bin/env bash
#define the function mktempdir

declare -p _bkit_mktemp > /dev/null 2>&1 && [[ ! ${1+$1} =~ ^-f ]] && return

declare -r _bkit_mktemp="$(dirname -- "$(readlink -ne -- "${BASH_SOURCE[0]}")")"
source "$_bkit_mktemp/traps.sh"

declare -p _bkit_TMPDIRS >/dev/null 2>&1 || declare -a _bkit_TMPDIRS=()

mktempdir() {
  #create a tempoary directory and set the name (using eval) on first argument
	declare -r tmpdir="${1:-_}"
	declare -r tmpname="$(mktemp -d --suffix=".bkit.$(basename --suffix=.sh -- "$0")")"

	_bkit_TMPDIRS+=( "$tmpname" )

	eval "declare -rg $tmpdir='$tmpname'" 

	(( ${#_bkit_TMPDIRS[@]} == 1 )) && atexit rmtempdir
	return 0
}

rmtempdir(){
  #We should be very carefull with "rm -rf" command 
  find "${_bkit_TMPDIRS[@]}" -maxdepth 0 -type d -name 'tmp.*.bkit.*' -print0 | xargs -r0I{} rm -rf "{}" ';'

  # delete also any bkit temporary file older than 30 days
  declare -r parent="$(dirname -- "$(mktemp -u)")"
  find "$parent" -path '*/tmp.*.bkit.*' -mtime +30 -delete 2>/dev/null
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]
then
  echo "The script '$0' is meant to be sourced"
  echo "Usage: source '$0'"
fi