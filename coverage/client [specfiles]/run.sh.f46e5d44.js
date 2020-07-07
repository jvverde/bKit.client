var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"declare -r sdir=\"$(dirname -- \"$(readlink -ne -- \"$0\")\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    3","line":"export PATH=\".:$sdir:$PATH\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    4","line":"declare -a args=()","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":"for arg in \"$@\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":"do"},
{"lineNum":"    7","line":"  [[ $arg =~ ^- ]] || arg=\"$(echo $arg|perl -lape \'s/^\"(.+)\"$/$1/\')\" #This is a workaround to remove extra quotes introduced my cmd.exe","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"  args+=( \"$arg\" )","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"done"},
{"lineNum":"   10","line":"exec ${@+\"${args[@]}\"}","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 7, "covered" : 0,};
var merged_data = [];
