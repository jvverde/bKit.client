#!/usr/bin/env bash
echo Install cygwin modules with apy-cyg
die(){
	echo -e "$@" && exit 1
}

[[ ${OSTYPE,,} != cygwin ]] && die Not Cygwin OSTYPE

cygcheck apt-cyg 1>/dev/null 2>&1 || die apt-cyg is not installed 

(( $# == 0 )) && die "Usage:\n\t$0 package_list_file"

while IFS= read -r pack
do
	apt-cyg install "$pack"
done < <(cat "$@" | sed '/^\s*$/d')