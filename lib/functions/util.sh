#!/usr/bin/env bash
declare -p _d37ca74ba4001d4dfbccfe2f3b8e55c4 >/dev/null 2>&1 && echo module utils apparentely already sourced && return
declare -r _d37ca74ba4001d4dfbccfe2f3b8e55c4=1

exists() {
	type "$1" >/dev/null 2>&1;
}

if exists tput && [[ -n $TERM && $TERM != dumb ]]
then
	say() {
		tput setaf 1
		tput setab 3
		echo -e "$@">&2 
		tput sgr0
	}
else
	say() {
		echo -e "$@">&2
	}
fi

msg () {
	for cnt in "${!BASH_SOURCE[@]}"
	do
		[[ "${BASH_SOURCE[$cnt]}" == "${BASH_SOURCE[0]}" ]] || break;	#find first bash_source which is not this file
	done

	say "${BASH_SOURCE[$cnt]}: Line ${BASH_LINENO[$cnt-1]}: $@">&2;		#show error with line number and file name

	for i in $(seq $cnt $(( ${#BASH_SOURCE[@]} - 2 )) )			#show call stach
	do
		say "\tCalled from ${BASH_SOURCE[$i+1]}" "${BASH_LINENO[$i]}">&2
	done
}

die() {
	CODE=$?
	msg "$@"
	exit $CODE;
}

declare ERROR=0
warn() {
	ERROR=1
	msg "$@"
}
