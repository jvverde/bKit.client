var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"echo Install cygwin modules with apy-cyg","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    3","line":"die(){"},
{"lineNum":"    4","line":"\techo -e \"$@\" && exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":"}"},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"[[ ${OSTYPE,,} != cygwin ]] && die Not Cygwin OSTYPE","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":""},
{"lineNum":"    9","line":"cygcheck apt-cyg 1>/dev/null 2>&1 || die apt-cyg is not installed","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":"(( $# == 0 )) && die \"Usage:\\n\\t$0 package_list_file\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":""},
{"lineNum":"   13","line":"while IFS= read -r pack","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":"do"},
{"lineNum":"   15","line":"\tapt-cyg install \"$pack\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":"done < <(cat \"$@\" | sed \'/^\\s*$/d\')","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 8, "covered" : 0,};
var merged_data = [];
