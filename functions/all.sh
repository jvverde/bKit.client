#!/usr/bin/env bash
THIS="$(readlink -ne -- "${BASH_SOURCE[0]}")"
DIR="$(dirname -- "$THIS")"

source <(find "$DIR" -maxdepth 1 -type f -name '*.sh' ! -path "$THIS" -exec cat "{}" ';')
