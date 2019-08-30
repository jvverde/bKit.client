#!/usr/bin/env bash
sdir="$(dirname -- "$(readlink -en -- "$0")")"               #Full DIR
sdir="${sdir%/client*}/client"
wdir="$(cygpath -w "$sdir")"

[[ ${OSTYPE,,} != cygwin ]] && echo "Not cygwin here" && exit 1

psexec="$(find "$sdir" /cygdrive/* -maxdepth 12 -iname psexec.exe -print -quit 2>/dev/null)"

"$psexec" -is -w "$wdir" "$wdir/bash.bat" "$@"