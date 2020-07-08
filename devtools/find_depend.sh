#https://medium.com/@pimterry/testing-your-shell-scripts-with-bats-abfca9bdc5b9
# Run this file (with 'entr' installed) to watch all files and rerun tests on changes
declare -r sdir=$(dirname -- "$(readlink -ne -- "$0")") #Full SDIR
declare -r src="${1:-"$(dirname -- "$sdir")"}" #Full SDIR

find "$src" \
  ! -path '*devtools/*' \
  ! -path '*spec/*' \
  -type f -iname '*.sh' \
  -exec grep -HPo '[$"/.a-z1-9]+\.sh"?' "{}" '+' #| cut -d: -f2|sed 's/"//g