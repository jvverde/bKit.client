#!/usr/bin/env bash
SDIR="$(dirname -- "$(readlink -ne -- "${BASH_SOURCE[0]}")")"
source "$SDIR/variables.sh"
VARDIR="$HOME/.bkit/$USER/var"
ETCDIR="$HOME/.bkit/$USER/etc"
mkdir -pv "$VARDIR" 
mkdir -pv "$ETCDIR" 
