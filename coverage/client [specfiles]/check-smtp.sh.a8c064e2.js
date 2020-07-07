var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"sdir=\"$(dirname -- \"$(readlink -ne -- \"$0\")\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    3","line":"source \"$sdir/lib/functions/all.sh\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    4","line":""},
{"lineNum":"    5","line":"server=\"${1:?Usage $0 servername [port]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":"port=${2:-25}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":"echo Contacting the server ... please wait!","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"exists nc && {","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"    nc -z $server $port || die Server $server not found","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":"} || die netcat is not installed","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":"echo ok","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 9, "covered" : 0,};
var merged_data = [];
