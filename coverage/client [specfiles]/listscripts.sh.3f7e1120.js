var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"#get a list of scripts and update package.json"},
{"lineNum":"    3","line":"die() {"},
{"lineNum":"    4","line":"  echo -e \"$@\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":"  exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":"}"},
{"lineNum":"    7","line":""},
{"lineNum":"    8","line":"declare -r sdir=$(dirname -- \"$(readlink -ne -- \"$0\")\")\t#Full SDIR","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"declare -r src=\"${1:-\"${sdir%/devtools*}\"}\"  #If not specified, assuming we are inside a tools directory under client area","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":"declare -r package=\"$src/package.json\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":""},
{"lineNum":"   12","line":"[[ -e $package ]] || die \"\'$package\' not found\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":""},
{"lineNum":"   14","line":"declare -r scripts=\"[$(find \"$src\" -maxdepth 1 -type f \\( -name \'*.sh\' -o -name \'*.bat\' \\) -printf \"\\\"%f\\\",\\n\"| sed \'${s/,$//g}\')]\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":"declare -r files=\"[$(find \"$src\" -mindepth 2 -type f ! -path \'**/.**\' -printf \"\\\"%P\\\",\\n\"| sed \'${s/,$//g}\')]\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":"declare -r old=\"${package}.old@$(date)\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   17","line":"cp \"$package\" \"$old\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   18","line":"jq \\","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   19","line":"  --argjson scripts \"$(echo $scripts| jq \'.\')\" \\"},
{"lineNum":"   20","line":"  --argjson files \"$(echo $files| jq \'.\')\" \\"},
{"lineNum":"   21","line":"  \'. | .scripts |= $scripts | .files |= $files\' \"$old\" > \"$package\""},
{"lineNum":"   22","line":"#sed -i.\"old@$(date)\" -E \"s/(.+scripts.+:)(.+?)/\\1 $scripts,/\" \"$package\""},
{"lineNum":"   23","line":"#sed -E \"s/(.+scripts.+:)(.+?)/\\1 $scripts,/\" \"$package\""},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 11, "covered" : 0,};
var merged_data = [];
