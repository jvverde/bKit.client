var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"type cygpath >/dev/null 2>&1 || die Cannot found cygpath","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    3","line":"SDIR=$(cygpath \"$(dirname -- \"$(readlink -ne -- \"$0\")\")\")\t#Full DIR","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    4","line":"source \"$SDIR/lib/functions/all.sh\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":""},
{"lineNum":"    6","line":"SUBINACL=$(find \"$SDIR/3rd-party\" -type f -name \"subinacl.exe\" -print -quit)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":"[[ -f $SUBINACL ]] || die SUBINACL.exe not found","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":""},
{"lineNum":"    9","line":"for FILE in \"$@\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":"do"},
{"lineNum":"   11","line":"\tSRC=$(cygpath -w $(readlink -en -- \"$FILE\"))","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":"\t\"$SUBINACL\" /nostatistic /playfile \"$SRC\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":"done"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 8, "covered" : 0,};
var merged_data = [];
