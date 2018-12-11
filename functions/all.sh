#!/usr/bin/env bash
declare -p DKGFJHFKYDGFNHGH > /dev/null 2>&1 && echo modules already inserted && return
DKGFJHFKYDGFNHGH="$(readlink -ne -- "${BASH_SOURCE[0]}")"
DIR="$(dirname -- "$DKGFJHFKYDGFNHGH")"

source <(find "$DIR" -maxdepth 1 -type f -name '*.sh' ! -path "$DKGFJHFKYDGFNHGH" -exec cat "{}" ';')
