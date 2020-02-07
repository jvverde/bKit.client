#!/usr/bin/env bash
sdir="$(dirname -- "$(readlink -en -- "$0")")"               #Full DIR
sdir="${sdir%/client*}/client"
third="$(find "$sdir" -type d -name '3rd-party' -print -quit)/SysInternals"

if [[ ${OSTYPE,,} == cygwin ]] 
then
	mkdir -pv "$third"
	pushd "$third" >/dev/null
	[[ -e SysinternalsSuite.zip ]] || wget -nv https://download.sysinternals.com/files/SysinternalsSuite.zip || echo "Can't find ysinternalsSuite.zip" 
	unzip -u SysinternalsSuite.zip
	chmod ugo+rx *.exe
	popd >/dev/null
else
	echo Not Cygwin OSTYPE
fi