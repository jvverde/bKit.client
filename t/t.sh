#!/usr/bin/env bash
set -e
trap 'rm -rf a' EXIT

doit(){
	mkdir -pv $(pwd)/a/b
	rm -rf $(pwd)/a/b/c
	eval "$@"
	../bkit.sh $(pwd)/a
}

file(){
	echo abc > $(pwd)/a/b/c
	echo abc > $(pwd)/a/file
}
hardlink(){
	ln $(pwd)/a/file $(pwd)/a/b/c
}
symlink(){
	ln -srf $(pwd)/a/file $(pwd)/a/b/c
}
directory(){
	mkdir -pv $(pwd)/a/b/c/ && echo abc > $(pwd)/a/b/c/file
}
pipe(){
	mkfifo $(pwd)/a/b/c
}
socket(){
	python -c "import socket as s; sock = s.socket(s.AF_UNIX); sock.bind('a/b/c')"
}

#doit file
declare -a list=(file hardlink symlink directory pipe socket)
for i in "${list[@]}"
do
	[[ ${last+isset} == isset ]] && echo -e "\n----------------- from $last to $i -----------------"
	doit "$i"
	last=$i
	for j in "${list[@]}"
	do
		[[ $last == $j ]] && continue
		echo -e "\n----------------- from $last to $j -----------------"
		doit "$j"
		echo -e "\n----------------- from $j to $last -----------------"
		doit "$last"
	done
done
