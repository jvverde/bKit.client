#!/usr/bin/env bash
echo Install paexec
sdir="$(dirname -- "$(readlink -en -- "$0")")"               #Full DIR
third="${sdir%/setup*}/3rd-party"

if [[ ${OSTYPE,,} == cygwin ]] 
then
	mkdir -pv "$third"
	pushd "$third" >/dev/null
	[[ -e paexec.exe ]] || wget --no-check-certificate -nv https://www.poweradmin.com/paexec/paexec.exe  2>&1
	chmod ugo+rx paexec.exe
	popd >/dev/null
else
	echo Not Cygwin OSTYPE
fi