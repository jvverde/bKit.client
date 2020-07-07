var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"#https://github.com/koalaman/shellcheck"},
{"lineNum":"    3","line":"declare EXCLUDE=12","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    4","line":"[[ $1 == --all ]] && unset EXCLUDE","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":""},
{"lineNum":"    6","line":"shellcheck ${EXCLUDE+--exclude=SC2155,SC2034} ../lib/functions/variables.sh","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":"shellcheck ../lib/functions/traps.sh","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"shellcheck ${EXCLUDE+--exclude=SC2155,SC2034} ../lib/functions/time.sh","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"shellcheck ${EXCLUDE+--exclude=SC2155} ../lib/functions/notify.sh","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":"shellcheck ${EXCLUDE+--exclude=SC2155} ../lib/functions/mktempdir.sh","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":"shellcheck ${EXCLUDE+--exclude=SC2155,SC2034} ../lib/functions/messages.sh","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":"shellcheck ${EXCLUDE+--exclude=SC2155} ../lib/functions/logs.sh","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":"shellcheck ${EXCLUDE+--exclude=SC2155,SC2034} ../lib/functions/exists.sh","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":"shellcheck ${EXCLUDE+--exclude=SC2155,SC2086} ../lib/functions/dirs.sh","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":"shellcheck ${EXCLUDE+--exclude=SC2155,SC2034} ../lib/functions/all.sh","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 12, "covered" : 0,};
var merged_data = [];
