var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"#update hashed strings7variables names on each function"},
{"lineNum":"    3","line":"sdir=$(dirname -- \"$(readlink -ne -- \"$0\")\")\t#Full SDIR","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    4","line":"sdir=\"${sdir%/tools*}\"  #assuming we are inside a tools directory under client area","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":""},
{"lineNum":"    6","line":"find \"$sdir/lib/functions\" -type f -print0|","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":"  xargs -r0I{} grep -PioH \'(?<=declare -p _)[a-f0-9]{32}(?= ?>)\' \"{}\" |","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"    while IFS=\':\' read -r file match","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"    do"},
{"lineNum":"   10","line":"      #compute new hash but without old hash"},
{"lineNum":"   11","line":"      hash=\"$(sed \"s#$match##\" \"$file\" | md5sum | awk \'{print $1}\')\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":"      [[ $match == $hash ]] || sed -i \"s#$match#$hash#\" \"$file\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":"    done"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 7, "covered" : 0,};
var merged_data = [];
