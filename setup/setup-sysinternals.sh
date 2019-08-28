#!/usr/bin/env bash
sdir="$(dirname -- "$(readlink -en -- "$0")")"               #Full DIR
sdir="${sdir%/client*}/client"
third="$(find "$sdir" -type d -name '3rd-party' -print -quit)/SysInternals"

if [[ ${OSTYPE,,} == cygwin ]] 
then
	mkdir -pv "$third"
	pushd "$third"
	wget -nv https://download.sysinternals.com/files/SysinternalsSuite.zip
	unzip SysinternalsSuite.zip
	popd
else
	echo Not Cygwin OSTYPE
fi