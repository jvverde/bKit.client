#!/usr/bin/env bash
declare -r sdir="$(dirname -- "$(readlink -en -- "$0")")"               #Full DIR
declare -r parent="${sdir%/setup*}" #assuming we are inside a setup directory under client area 

die(){
	echo -e "$@" && exit 1
}

[[ ${OSTYPE,,} != cygwin ]] && die Not Cygwin OSTYPE

uname -a|grep -q x86_64 && declare -r OSARCH=x64 || declare -r OSARCH=x86
uname -s|grep -q CYGWIN_NT-5 && declare -r XP='-XP' || declare -r XP=''

declare -r shadow="$(find "$sdir" -iname "ShadowSpawn*${OSARCH}${XP}.zip")"

[[ -e $shadow ]] || die "Can't find ShadowSpawn*${OSARCH}${XP}"

declare -r target="$parent/3rd-party/shadowspawn"

[[ -d $target ]] || mkdir -pv "$target"

unzip -u "$shadow" -d "$target"
chmod ugo+rx "$target"/*.exe