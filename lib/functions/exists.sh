#!/usr/bin/env bash
#Just check ih something exists
declare -F exists > /dev/null 2>&1 && [[ ! ${1+$1} =~ ^-f ]] && return

exists() {
	type "$1" >/dev/null 2>&1;
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]
then
  echo "The script '$0' is meant to be sourced"
  echo "Usage: source '$0'"
fi