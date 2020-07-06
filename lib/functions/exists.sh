#!/usr/bin/env bash
#Just check ih something exists
declare -F exists > /dev/null 2>&1 && [[ ! ${1+$1} =~ ^-f ]] && return

exists() {
	type "$1" >/dev/null 2>&1;
}
