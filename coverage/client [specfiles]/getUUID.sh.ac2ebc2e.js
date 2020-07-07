var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"#As the name says. Get thee UUId of partion/volume of a given path"},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"set -u","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":"sdir=$(dirname -- \"$(readlink -en -- \"$0\")\")\t#Full sdir","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":"source \"$sdir/functions/all.sh\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":""},
{"lineNum":"    8","line":"[[ ${1+isset} == isset ]] || die \"Usage:\\n\\t$0 path\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"[[ -e $1 ]] || die Cannot find $1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":"backupdir=\"$1\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":""},
{"lineNum":"   13","line":"exists cygpath && backupdir=$(cygpath \"$1\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":""},
{"lineNum":"   15","line":"backupdir=$(readlink -ne \"$backupdir\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":""},
{"lineNum":"   17","line":"uuid=$(bash \"$sdir/drive.sh\" \"$backupdir\"|cut -d\'|\' -f2)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   18","line":""},
{"lineNum":"   19","line":"echo \"$uuid\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 10, "covered" : 0,};
var merged_data = [];
