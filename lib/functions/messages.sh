#!/usr/bin/env bash
declare -p _bkit_messages > /dev/null 2>&1 && [[ ! ${1+$1} =~ ^-f ]] && return

declare _bkit_messages="$(dirname -- "$(readlink -ne -- "${BASH_SOURCE[0]}")")"

define_say() {
	source "$_bkit_messages/exists.sh"
	if exists tput && [[ -n $TERM && $TERM != dumb ]]
	then
		say() {
			tput setab 7
			tput setaf 1
			echo -e "$@">&2 
			tput sgr0
			tput el
		}
	else
		say() {
			echo -e "$@">&2
		}
	fi
}

msg () {
	for cnt in "${!BASH_SOURCE[@]}"
	do
		[[ "${BASH_SOURCE[$cnt]}" == "${BASH_SOURCE[0]}" ]] || break;	#find first bash_source which is not this file
	done

	say "${BASH_SOURCE[$cnt]}: Line ${BASH_LINENO[$cnt-1]}: $*">&2;		#show error with line number and file name

	for i in $(seq "$cnt" $(( ${#BASH_SOURCE[@]} - 2 )) )			#Show caller stack
	do
		say "\tCalled from ${BASH_SOURCE[$i+1]}" "${BASH_LINENO[$i]}">&2
	done
}

die() {
	declare errorcode=$?
	(( errorcode == 0 )) && errorcode=1 #Unless there is a previous error code the exit code should be 1
	msg "$@"
	exit $errorcode;
}

warn() {
	declare -g ERROR=1
	msg "$@"
}

${__SOURCED__:+return} #Intended for shellspec tests

define_say

if [[ ${BASH_SOURCE[0]} == "$0" ]]
then
  echo "The script '$0' is meant to be sourced"
  echo "Usage: source '$0'"
fi