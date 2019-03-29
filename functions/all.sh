#!/usr/bin/env bash
declare -p DKGFJHFKYDGFNHGH > /dev/null 2>&1 && echo modules already inserted >&2 && return
DKGFJHFKYDGFNHGH="$(readlink -ne -- "${BASH_SOURCE[0]}")"
dir="$(dirname -- "$DKGFJHFKYDGFNHGH")"

source <(find "$dir" -maxdepth 1 -type f -name '*.sh' ! -path "$DKGFJHFKYDGFNHGH" -exec cat "{}" ';')
