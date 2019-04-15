#!/usr/bin/env bash
dirsinit(){
	local user="$(id -nu)"
	local homedir="$( getent passwd "$user" | cut -d: -f6 )"
	VARDIR="$homedir/.bkit/var"
	ETCDIR="$homedir/.bkit/etc"
}

dirsinit

mkdir -pv "$VARDIR"
mkdir -pv "$ETCDIR" 
