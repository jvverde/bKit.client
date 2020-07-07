#!/usr/bin/env bash
declare -r sdir=$(dirname -- "$(readlink -ne -- "$0")") #Full SDIR
declare -r target="$(dirname -- "$sdir")"/spec/_auto_ #Full SDIR

[[ -d $target ]] || mkdir -pv "$target"

exec {OUT}> >(tee "$target"/_status_spec.sh)

while [[ ${1:+$1} =~ ^- ]]
do
  declare key="$1" && shift
  case "$key" in
    -o=*|--output=*)
      exec {OUT}>"${key#*=}"
    ;;
    -o|--output) 
      exec {OUT}>"$1" && shift
    ;;
  esac
done

[[ ${2+x} == x ]] && exec {OUT}>"$2"

declare -r src="${1:-$(dirname -- "$sdir")}"

while IFS= read -r -d $'\0' file
do
cat <<EOF
Describe '$file'
  Include $file
  It 'check status success'
    When run source $file
    The status should be success
  End
End
EOF

done < <(find "$src" -type f -name '*.sh' -print0) >&$OUT


