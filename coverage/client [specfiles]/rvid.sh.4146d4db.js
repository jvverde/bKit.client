var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"#comput RVID -- Remote Volume ID"},
{"lineNum":"    3","line":"issourced(){"},
{"lineNum":"    4","line":"\t[[ \"${BASH_SOURCE[0]}\" != \"${0}\" ]]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":"}"},
{"lineNum":"    6","line":"declare rviddir=\"$(dirname -- \"$(readlink -ne -- \"${BASH_SOURCE[0]:-$0}\")\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":"source \"$rviddir/functions/all.sh\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":""},
{"lineNum":"    9","line":"export_rvid(){"},
{"lineNum":"   10","line":"\tsrc=\"$(readlink -ne -- \"$1\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":"\tIFS=\'|\' read -r volumename volumeserialnumber filesystem drivetype <<<$(\"$rviddir/drive.sh\" \"$src\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":"\texists cygpath && declare drive=\"$(cygpath -w \"$src\")\" && drive=\"${drive%%:*}\"                      #remove anything after : (if any)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":"\texport BKIT_DRIVE=\"${drive:-_}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":"\texport BKIT_VOLUMESERIALNUMBER=\"${volumeserialnumber:-_}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":"\texport BKIT_VOLUMENAME=\"${volumename:-_}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":"\texport BKIT_DRIVETYPE=\"${drivetype:-_}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   17","line":"\texport BKIT_FILESYSTEM=\"${filesystem:-_}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   18","line":"\texport BKIT_RVID=\"$BKIT_DRIVE.$BKIT_VOLUMESERIALNUMBER.$BKIT_VOLUMENAME.$BKIT_DRIVETYPE.$BKIT_FILESYSTEM\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   19","line":"\tissourced || echo $BKIT_RVID","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   20","line":"}"},
{"lineNum":"   21","line":"export_rvid \"${1:-.}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 14, "covered" : 0,};
var merged_data = [];
