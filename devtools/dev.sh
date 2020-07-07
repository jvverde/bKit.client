#https://medium.com/@pimterry/testing-your-shell-scripts-with-bats-abfca9bdc5b9
# Run this file (with 'entr' installed) to watch all files and rerun tests on changes
declare -r sdir=$(dirname -- "$(readlink -ne -- "$0")") #Full SDIR

ls -d **/* | entr "$sdir"/test_spec.sh