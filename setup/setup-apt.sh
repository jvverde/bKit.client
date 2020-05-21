#!/usr/bin/env bash
echo Install apy-cyg
declare -r sdir="$(dirname -- "$(readlink -en -- "$0")")"               #Full DIR
#https://github.com/transcode-open/apt-cyg
# or https://github.com/kou1okada/apt-cyg
#https://stackoverflow.com/questions/9260014/how-do-i-install-cygwin-components-from-the-command-line
if [[ ${OSTYPE,,} == cygwin ]] 
then
	#cygcheck apt-cyg 1>/dev/null 2>&1 && echo yes
	declare -r tmp="$(mktemp -d)"
  trap "rm -rf $tmp" EXIT SIGINT SIGTERM
	pushd "$tmp" >/dev/null
  IFS= read -t 1 -r url < <(cat "$sdir/urls/apt-cyg.url" | sed -E '/^(\s|\r)*$/d')
	wget -nv -O apt-cyg "$url" 2>&1|| echo "Can't download apt-cyg"
	install apt-cyg /bin
	popd >/dev/null
else
	echo Not Cygwin OSTYPE
fi