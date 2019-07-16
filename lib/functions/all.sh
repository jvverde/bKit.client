#!/usr/bin/env bash
declare -p _4414d6399d04b360b28fcbc253b4c87d > /dev/null 2>&1 && return
declare -r _4414d6399d04b360b28fcbc253b4c87d=1

declare -r mydir="$(readlink -ne -- "${BASH_SOURCE[0]}")"

dir="$(dirname -- "$mydir")"

source <(find "$dir" -maxdepth 1 -type f -name '*.sh' ! -path "$mydir" -exec cat "{}" ';')
