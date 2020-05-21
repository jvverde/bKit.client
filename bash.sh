#!/usr/bin/env bash
#exec sudo "$0" "$@"
declare -r sdir="$(dirname -- "$(readlink -ne -- "$0")")"
export PATH=".:$sdir:$PATH"
exec "$@"