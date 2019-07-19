#!/usr/bin/env bash
declare -p _ff1d0f529b3a89edaa94571a1c8b095c >/dev/null 2>&1 && echo module dirs apparentely already sourced && return

_ff1d0f529b3a89edaa94571a1c8b095c(){
	local user="$(id -nu)"
	local homedir="$( getent passwd "$user" | cut -d: -f6 )"
	VARDIR="$homedir/.bkit/var"
	ETCDIR="$homedir/.bkit/etc"
}

_ff1d0f529b3a89edaa94571a1c8b095c

mkdir -pv "$VARDIR"
mkdir -pv "$ETCDIR" 
