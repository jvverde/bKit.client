#!/usr/bin/env bash

#https://github.com/transcode-open/apt-cyg
if [[ ${OSTYPE,,} == cygwin ]] 
then
	#cygcheck apt-cyg 1>/dev/null 2>&1 && echo yes
	declare -r tmp="$(mktemp -d)"
	pushd $tmp
	wget -nv https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg
	install apt-cyg /bin && rm apt-cyg
	popd
	rmdir -v "$tmp"
else
	echo Not Cywin OSTYPE
fi