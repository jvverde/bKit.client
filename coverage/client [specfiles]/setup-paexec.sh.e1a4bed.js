var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"echo Install paexec","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    3","line":"sdir=\"$(dirname -- \"$(readlink -en -- \"$0\")\")\"               #Full DIR","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    4","line":"third=\"${sdir%/setup*}/3rd-party\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":""},
{"lineNum":"    6","line":"if [[ ${OSTYPE,,} == cygwin ]]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":"then"},
{"lineNum":"    8","line":"\tmkdir -pv \"$third\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"\tpushd \"$third\" >/dev/null","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":"\t[[ -e paexec.exe ]] || wget --no-check-certificate -nv https://www.poweradmin.com/paexec/paexec.exe  2>&1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":"\tchmod ugo+rx paexec.exe","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":"\tpopd >/dev/null","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":"else"},
{"lineNum":"   14","line":"\techo Not Cygwin OSTYPE","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":"fi"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 10, "covered" : 0,};
var merged_data = [];
