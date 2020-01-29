#!/usr/bin/env bash
sdir="$(dirname -- "$(readlink -en -- "$0")")"               #Full DIR
third="${sdir%/client*}/client/3rd-party"

if [[ ${OSTYPE,,} == cygwin ]] 
then
	mkdir -pv "$third"
	pushd "$third" >/dev/null
	[[ -e paexec.exe ]] || wget -nv https://www.poweradmin.com/paexec/paexec.exe
	chmod ugo+rx paexec.exe
	popd >/dev/null
else
	echo Not Cygwin OSTYPE
fi