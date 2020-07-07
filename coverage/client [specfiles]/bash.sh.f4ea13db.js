var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"#exec sudo \"$0\" \"$@\""},
{"lineNum":"    3","line":"declare -r sdir=\"$(dirname -- \"$(readlink -ne -- \"$0\")\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    4","line":"export PATH=\".:$sdir:$PATH\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":"exec \"$@\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 3, "covered" : 0,};
var merged_data = [];
