#!/usr/bin/env bash
declare -p _fa5db1cec69d83e1bb3898143fd1002c >/dev/null 2>&1 && echo module dirs apparentely already sourced && return

_fa5db1cec69d83e1bb3898143fd1002c(){
	local user="$(id -nu)"
	local homedir="$( getent passwd "$user" | cut -d: -f6 )"
	true ${homedir:="$HOME"}
	true ${homedir:="/home/$user"}
	[[ -e $homedir ]] || mkdir -pv "$homedir"
	VARDIR="$homedir/.bkit/var"
	ETCDIR="$homedir/.bkit/etc"
	[[ -e /home/$user ]] || ln -svT "$homedir" "/home/$user"
}

_fa5db1cec69d83e1bb3898143fd1002c

mkdir -pv "$VARDIR"
mkdir -pv "$ETCDIR" 