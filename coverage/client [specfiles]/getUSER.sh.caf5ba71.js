var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"{"},
{"lineNum":"    3","line":"  set -u","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    4","line":"  declare -r sdir=$(dirname -- \"$(readlink -en -- \"$0\")\") #Full sdir","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":"  source \"$sdir/functions/all.sh\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":"} >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":""},
{"lineNum":"    8","line":"echo \"$BKITUSER\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 5, "covered" : 0,};
var merged_data = [];
