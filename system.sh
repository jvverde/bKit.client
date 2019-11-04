#!/usr/bin/env bash
sdir="$(dirname -- "$(readlink -en -- "$0")")"               #Full DIR
sdir="${sdir%/client*}/client"
wdir="$(cygpath -w "$sdir")"

[[ ${OSTYPE,,} != cygwin ]] && echo "Not cygwin here" && exit 1

psexec="$(find "$sdir" -iname psexec.exe -print -quit 2>/dev/null)"

[[ -x $psexec ]] || echo "'$psexec' is not executable"

"$psexec" -is -w "$wdir" "$wdir/bash.bat" "$@"