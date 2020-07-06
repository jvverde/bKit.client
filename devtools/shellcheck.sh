#!/usr/bin/env bash
declare EXCLUDE=12
[[ $1 == --all ]] && unset EXCLUDE 

shellcheck ${EXCLUDE+--exclude=SC2155,SC2034} ../lib/functions/variables.sh
shellcheck ../lib/functions/traps.sh
shellcheck ${EXCLUDE+--exclude=SC2155,SC2034} ../lib/functions/time.sh
shellcheck ${EXCLUDE+--exclude=SC2155} ../lib/functions/notify.sh
shellcheck ${EXCLUDE+--exclude=SC2155} ../lib/functions/mktempdir.sh
shellcheck ${EXCLUDE+--exclude=SC2155,SC2034} ../lib/functions/messages.sh
shellcheck ${EXCLUDE+--exclude=SC2155} ../lib/functions/logs.sh
shellcheck ${EXCLUDE+--exclude=SC2155,SC2034} ../lib/functions/exists.sh
shellcheck ${EXCLUDE+--exclude=SC2155,SC2086} ../lib/functions/dirs.sh
shellcheck ${EXCLUDE+--exclude=SC2155,SC2034} ../lib/functions/all.sh
