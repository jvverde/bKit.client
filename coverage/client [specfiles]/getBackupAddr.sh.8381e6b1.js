var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"SDIR=$(dirname -- \"$(readlink -ne -- \"$0\")\")\t#Full DIR","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    3","line":"source \"$SDIR/lib/functions/all.sh\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    4","line":""},
{"lineNum":"    5","line":"INITFILE=$ETCDIR/default/conf.init","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"[[ -e $INITFILE ]] || die \"file $INITFILE not found\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":""},
{"lineNum":"    9","line":"grep -Pom 1 \'(?<=@).+?(?=:)\' \"$INITFILE\" && exit 0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":"die \'Server Address not found\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 6, "covered" : 0,};
var merged_data = [];
