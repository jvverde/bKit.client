#!/bin/bash
OS=$(uname -o|tr '[:upper:]' '[:lower:]')
#[[ $OS == 'cygwin' ]] && cygstart --action=runas "$@" && exit
#type sudo >/dev/null 2>&1 && sudo "$@" && exit
#echo "Don't find neither sudo nor cygstart"
echo 'aqui'
[[ $OS == cygwin || $UID -eq 0 ]] || exec sudo "$0" "$@"
[[ $OS == cygwin ]] && !(id -G|grep -qE '\b544\b') && {
	echo I am to going to runas Administrator
	cygstart -w --action=runas /bin/bash bash "$0" "$@" && exit
}
echo aqui vou eu
bash "$@"