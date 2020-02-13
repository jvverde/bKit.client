#!/usr/bin/env bash
(( $(id -u) == 0 )) || exec sudo "$0" "$@"
SDIR="$(dirname -- "$(readlink -ne -- "$0")")"                          #Full DIR

DIR="${1:? $'\n\t'Usage: $0 path}" || exit 1
declare -A parents
declare -A snaps
declare -A childrens
while read -r snap
do 
	show=$(btrfs su show "$DIR/$snap")
	snaps[$snap]=$snap
	#childrens+=$(echo "$show"|sed '1,/Snapshot(s):/d'|perl -lape 's/^\s*(.+)\s*$/$1/')
	while read -r child
	do
		childrens["$child"]=1
	done < <(echo "$show"|sed '1,/Snapshot(s):/d'|perl -lape 's/^\s*(.+)\s*$/$1/')
	echo "$show"
done < <(btrfs su list $DIR|awk '{print $9}') 

for child in "${!childrens[@]}"
do
	echo child=$child
	unset snaps["$child"]
done
echo +++++
echo "${!snaps[@]}"
echo -----
