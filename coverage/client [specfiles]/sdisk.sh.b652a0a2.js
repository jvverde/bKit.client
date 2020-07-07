var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"sdir=\"$(dirname -- \"$(readlink -ne -- \"$0\")\")\"       #Full DIR","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"source \"$sdir/ccrsync.sh\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":""},
{"lineNum":"    6","line":"rsync --list-only \"$BACKUPURL\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":""},
{"lineNum":"    8","line":""},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 3, "covered" : 0,};
var merged_data = [];
