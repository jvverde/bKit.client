#!/usr/bin/env bash
echo Install ShadowSpawn
declare -r sdir="$(dirname -- "$(readlink -en -- "$0")")"               #Full DIR
declare -r parent="${sdir%/setup*}" #assuming we are inside a setup directory under client area 

die(){
	echo -e "$@" && exit 1
}

[[ ${OSTYPE,,} != cygwin ]] && die Not Cygwin OSTYPE

uname -a|grep -q x86_64 && declare -r OSARCH=x64 || declare -r OSARCH=x86

IFS= read -t 1 -r url < <(cat "$sdir/urls/ShadowSpawn${OSARCH}.url" | sed -E '/^(\s|\r)*$/d')

declare -r name="${url##*/}" 
declare -r shadow="$sdir/ShadowSpawn/$name"

[[ -e $shadow ]] || {
  mkdir -pv "$sdir/ShadowSpawn/"
  wget -nv -O "$shadow" "$url" 2>&1 || echo "Can't download ShadowSpawn"
}

[[ -e $shadow ]] || die "Can't find ShadowSpawn*${OSARCH}${XP}"

declare -r target="$parent/3rd-party/shadowspawn"

[[ -d $target ]] || mkdir -pv "$target"

unzip -u "$shadow" -d "$target"
chmod ugo+rx "$target"/*.exe