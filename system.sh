#!/usr/bin/env bash
declare -r sdir="$(dirname -- "$(readlink -en -- "$0")")"               #Full DIR
declare -r wdir="$(cygpath -w "$sdir")"
declare -r batch="$(cygpath -w "$sdir/bash.bat")"

[[ ${OSTYPE,,} != cygwin ]] && echo "Not cygwin here" && exit 1

declare paexec="$sdir/3rd-party/paexec.exe"

[[ -x $paexec ]] || paexec="$(find "$sdir" -iname paexec.exe -print -quit 2>/dev/null)"

[[ -x $paexec ]] || echo "'$paexec' is not executable"

unset i

[[ -z $1 ]] && declare -r i='i' #run paexec iteratively if no args are provided

0</dev/null "$paexec" -s ${i:+-$i} -w "$wdir" "$batch" ${@:+"${@}"}
