#!/usr/bin/env bash
declare -p _d6896e345fdb50c9693f1023c6210815 > /dev/null 2>&1 && return
declare -r _d6896e345fdb50c9693f1023c6210815=1

true ${USER:="$(id -un)"}

declare -r mydir="$(readlink -ne -- "${BASH_SOURCE[0]}")"

dir="$(dirname -- "$mydir")"

source <(find "$dir" -maxdepth 1 -type f -name '*.sh' ! -path "$mydir" -exec cat "{}" ';')
