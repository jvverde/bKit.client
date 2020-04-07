#!/usr/bin/env bash
#Get or set (permanently or not) the server
#And also export BKIT_CONFIG when sourced
declare -r sdir="$(dirname -- "$(readlink -ne -- "$0")")"       #Full DIR

source "$sdir/lib/functions/all.sh"

[[ ${ETCDIR+isset} == isset ]] || die "ETCDIR is not defined"

declare -r CONFDIR="$ETCDIR/server"

find "$CONFDIR" -maxdepth 1 -mindepth 1 -type d -printf "%f\n"