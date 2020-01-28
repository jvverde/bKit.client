#!/usr/bin/env bash
declare -r sdir="$(dirname -- "$(readlink -en -- "$0")")"               #Full DIR
declare -r cdir="${sdir%/client*}/client"
declare -r wdir="$(cygpath -w "$cdir")"
declare -r batch="$(cygpath -w "$cdir/psexecutable.bat")"

[[ ${OSTYPE,,} != cygwin ]] && echo "Not cygwin here" && exit 1

declare psexec="$cdir/3rd-party/SysInternals/psexec.exe"

[[ -x $psexec ]] || psexec="$(find "$cdir" -iname psexec.exe -print -quit 2>/dev/null)"

[[ -x $psexec ]] || echo "'$psexec' is not executable"

unset i

[[ -z $1 ]] && declare -r i='i' #run psexec iteratively if no args are provided
echo aqui vai ${@:+"${@}"}
"$psexec" -s${i:+$i} -w "$wdir" cmd /c "$batch" ${@:+"${@}"}
echo aqui foi ${@:+"${@}"}
