#!/usr/bin/env bash
sdir="$(dirname -- "$(readlink -en -- "$0")")"               #Full DIR

[[ ${OSTYPE,,} != cygwin ]] && echo "Not cygwin here" && exit 1

if (id -G|grep -qE '\b544\b')
then
	bash  "$@"
else
	cygstart --action=runas "$sdir/bash.bat" "$@"
fi
