#!/usr/bin/env bash
sdir="$(dirname -- "$(readlink -en -- "$0")")"               #Full DIR
sdir="${sdir%/client*}/client"

[[ ${OSTYPE,,} != cygwin ]] && echo "Not cygwin here" && exit 1

if (id -G|grep -qE '\b544\b')
then
	echo already admin
	bash  "$@"
else
	cygstart --wait --action=runas "$sdir/bash.bat" "$@"
fi
