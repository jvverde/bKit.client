#!/usr/bin/env bash
#https://github.com/koalaman/shellcheck
declare -r sdir=$(dirname -- "$(readlink -ne -- "$0")") #Full SDIR
declare -r src="${1:-$(dirname -- "$sdir")}"

declare EXCLUDE=12
[[ $1 == --all ]] && unset EXCLUDE 

shellcheck ${EXCLUDE+--exclude=SC2155,SC2034} "$src"/lib/functions/variables.sh
shellcheck "$src"/lib/functions/traps.sh
shellcheck ${EXCLUDE+--exclude=SC2155,SC2034} "$src"/lib/functions/time.sh
shellcheck ${EXCLUDE+--exclude=SC2155} "$src"/lib/functions/notify.sh
shellcheck ${EXCLUDE+--exclude=SC2155} "$src"/lib/functions/mktempdir.sh
shellcheck ${EXCLUDE+--exclude=SC2155,SC2034,SC2120,SC2119} "$src"/lib/functions/messages.sh
shellcheck ${EXCLUDE+--exclude=SC2155} "$src"/lib/functions/logs.sh
shellcheck ${EXCLUDE+--exclude=SC2155,SC2034} "$src"/lib/functions/exists.sh
shellcheck ${EXCLUDE+--exclude=SC2155,SC2086} "$src"/lib/functions/dirs.sh
shellcheck ${EXCLUDE+--exclude=SC2155,SC2034,SC2086} "$src"/lib/functions/all.sh
