var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"echo Install apy-cyg","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    3","line":"declare -r sdir=\"$(dirname -- \"$(readlink -en -- \"$0\")\")\"               #Full DIR","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    4","line":"#https://github.com/transcode-open/apt-cyg"},
{"lineNum":"    5","line":"# or https://github.com/kou1okada/apt-cyg"},
{"lineNum":"    6","line":"#https://stackoverflow.com/questions/9260014/how-do-i-install-cygwin-components-from-the-command-line"},
{"lineNum":"    7","line":"if [[ ${OSTYPE,,} == cygwin ]]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"then"},
{"lineNum":"    9","line":"\t#cygcheck apt-cyg 1>/dev/null 2>&1 && echo yes"},
{"lineNum":"   10","line":"\tdeclare -r tmp=\"$(mktemp -d)\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":"  trap \"rm -rf $tmp\" EXIT SIGINT SIGTERM","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":"\tpushd \"$tmp\" >/dev/null","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":"  IFS= read -t 1 -r url < <(cat \"$sdir/urls/apt-cyg.url\" | sed -E \'/^(\\s|\\r)*$/d\')","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":"\twget -nv -O apt-cyg \"$url\" 2>&1|| echo \"Can\'t download apt-cyg\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":"\tinstall apt-cyg /bin","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":"\tpopd >/dev/null","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   17","line":"else"},
{"lineNum":"   18","line":"\techo Not Cygwin OSTYPE","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   19","line":"fi"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 11, "covered" : 0,};
var merged_data = [];
