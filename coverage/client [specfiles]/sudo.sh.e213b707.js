var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"sdir=\"$(dirname -- \"$(readlink -en -- \"$0\")\")\"               #Full DIR","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"[[ ${OSTYPE,,} != cygwin ]] && echo \"Not cygwin here\" && exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":""},
{"lineNum":"    6","line":"if (id -G|grep -qE \'\\b544\\b\')","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":"then"},
{"lineNum":"    8","line":"\tbash  \"$@\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"else"},
{"lineNum":"   10","line":"\tcygstart --action=runas \"$sdir/bash.bat\" \"$@\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":"fi"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 5, "covered" : 0,};
var merged_data = [];
