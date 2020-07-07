var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"#exec sudo \"$0\" \"$@\""},
{"lineNum":"    3","line":"die() {"},
{"lineNum":"    4","line":"  echo -e \"$@\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":"  exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":"}"},
{"lineNum":"    7","line":""},
{"lineNum":"    8","line":"[[ ${1+isset} == isset ]] || die \"Usage:\\n\\t$0 pid\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":""},
{"lineNum":"   10","line":"pgid=\"/proc/$1/pgid\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":""},
{"lineNum":"   12","line":"[[ -e $pgid ]] || die \"Can\'t find \'$pgid\' file\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":""},
{"lineNum":"   14","line":"kill -- \"-$(cat \"$pgid\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 6, "covered" : 0,};
var merged_data = [];
