#!/usr/bin/env bash
declare -r sdir="$(dirname -- "$(readlink -en -- "$0")")"               #Full DIR
#https://github.com/transcode-open/apt-cyg
# or https://github.com/kou1okada/apt-cyg
#https://stackoverflow.com/questions/9260014/how-do-i-install-cygwin-components-from-the-command-line
if [[ ${OSTYPE,,} == cygwin ]] 
then
	#cygcheck apt-cyg 1>/dev/null 2>&1 && echo yes
	declare -r tmp="$(mktemp -d)"
	pushd $tmp
	wget -nv https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg \
		|| echo "Can't download apt-cyg"
	install apt-cyg /bin && rm apt-cyg
	popd
	rmdir -v "$tmp"
else
	echo Not Cygwin OSTYPE
fi