var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"declare -r sdir=\"$(dirname -- \"$(readlink -en -- \"$0\")\")\"               #Full DIR","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    3","line":"declare -r wdir=\"$(cygpath -w \"$sdir\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    4","line":"declare -r batch=\"$(cygpath -w \"$sdir/bash.bat\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":""},
{"lineNum":"    6","line":"[[ ${OSTYPE,,} != cygwin ]] && echo \"Not cygwin here\" && exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":""},
{"lineNum":"    8","line":"declare paexec=\"$sdir/3rd-party/paexec.exe\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":""},
{"lineNum":"   10","line":"[[ -x $paexec ]] || paexec=\"$(find \"$sdir\" -iname paexec.exe -print -quit 2>/dev/null)\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":""},
{"lineNum":"   12","line":"[[ -x $paexec ]] || echo \"\'$paexec\' is not executable\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":""},
{"lineNum":"   14","line":"unset i","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":""},
{"lineNum":"   16","line":"[[ -z $1 ]] && declare -r i=\'i\' #run paexec iteratively if no args are provided","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   17","line":""},
{"lineNum":"   18","line":"0</dev/null \"$paexec\" -s ${i:+-$i} -w \"$wdir\" \"$batch\" ${@:+\"${@}\"}","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 10, "covered" : 0,};
var merged_data = [];
