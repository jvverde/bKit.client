var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"SDIR=$(dirname \"$(readlink -f \"$0\")\")       #Full DIR","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"SDRIVE=$SYSTEMDRIVE","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":"[[ -n $SDRIVE ]] || SDRIVE=$(cmd /C echo %SystemDrive%|sed -E \'s#\\r##\')","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":"set -f","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":"while read -r LINE","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"do"},
{"lineNum":"    9","line":"\t[[ $LINE =~ ^# || $LINE =~ ^[[:space:]]*$ ]] && continue","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":"\tDIR=$(cmd /C \"echo $LINE\"|sed -E \'s#\\r##\')","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":"\t[[ $DIR =~ ^\\\\ ]] && DIR=\"$SDRIVE$DIR\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":"\tDIR=$(cygpath -u \"$DIR\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":"\t[[ -z $DIR ]] && {","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":"\t\tLINE=$(echo $LINE | sed -E \'s#%([^%]+)%#$\\U\\1#g\')","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":"\t\tDIR=$(sh -c \"echo $LINE\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   17","line":"\t\t[[ $DIR =~ ^\\\\ ]] && DIR=\"$SDRIVE$DIR\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   18","line":"\t\tDIR=$(cygpath -u \"$DIR\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   19","line":"\t}"},
{"lineNum":"   20","line":"\t[[ -n $DIR ]] && {","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   21","line":"\t\t[[ $DIR =~ ^/ ]] && echo -/ $DIR || echo - $DIR","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   22","line":"\t}"},
{"lineNum":"   23","line":"done"},
{"lineNum":"   24","line":""},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 16, "covered" : 0,};
var merged_data = [];
