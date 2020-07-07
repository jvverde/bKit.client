var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"declare -F _bkit_source_all > /dev/null 2>&1 && [[ ! ${1+$1} =~ ^-f ]] && return","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"_bkit_source_all(){"},
{"lineNum":"    5","line":""},
{"lineNum":"    6","line":"\tdeclare -r myself=\"$(readlink -ne -- \"${BASH_SOURCE[0]}\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":""},
{"lineNum":"    8","line":"\tdeclare -r dir=\"$(dirname -- \"$myself\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":""},
{"lineNum":"   10","line":"\t#source <(find \"$dir\" -maxdepth 1 -type f -name \'*.sh\' ! -path \"$myself\" -exec cat \"{}\" \';\')"},
{"lineNum":"   11","line":"\twhile IFS= read -r -d $\'\\0\' file","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":"\tdo"},
{"lineNum":"   13","line":"\t\tsource \"$file\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":"\tdone < <(find \"$dir\" -maxdepth 1 -type f -name \'*.sh\' ! -path \"$myself\" -print0)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":"  true \"${BKITUSER:=\"$(id -un)\"}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":"}"},
{"lineNum":"   17","line":""},
{"lineNum":"   18","line":"_bkit_source_all","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 8, "covered" : 0,};
var merged_data = [];
