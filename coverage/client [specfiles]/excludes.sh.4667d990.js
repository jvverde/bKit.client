var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"#Make a filter from excludes files in excludir directory"},
{"lineNum":"    3","line":"set -u","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    4","line":"declare -r sdir=\"$(dirname \"$(readlink -f \"$0\")\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":"declare -r base=\"${sdir%/lib*}\"               #assuming we are inside a lib directory under client area","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"declare -r excludedir=\"${1:-\"$base/excludes\"}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":""},
{"lineNum":"    9","line":"find \"$excludedir/all\" -type f -print0 |xargs -r0I{} cat \"{}\" | grep -vP ^# | perl -lape \'s#^#-/ #\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":"find \"$excludedir/bkit\" -type f -exec cat \"{}\" \'+\' | grep -vP ^# | perl -lape \"s#^#-/ $base/#\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":"#[[ -e $EXCLUDESALL ]] && cat \"$EXCLUDESALL\" | sed -E \'s#.+#-/ &#\' >> \"$EXCL\""},
{"lineNum":"   12","line":"OS=$(uname -o |tr \'[:upper:]\' \'[:lower:]\')","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":""},
{"lineNum":"   14","line":"[[ $OS == cygwin ]] && {","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":"\tbash \"$sdir/excludes/hklm.sh\"| bash \"$sdir/excludes/w2f.sh\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":"\tfind \"$excludedir/windows\" -type f -print0 | xargs -r0I{} cat \"{}\" | grep -vP ^# | bash \"$sdir/excludes/w2f.sh\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   17","line":"}"},
{"lineNum":"   18","line":""},
{"lineNum":"   19","line":"[[ $OS != cygwin ]] && {","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   20","line":"\tfind \"$excludedir/unix\" -type f -print0 | xargs -r0I{} cat \"{}\" | grep -vP ^# | sed -E \'s#.+#-/ &#\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   21","line":"}"},
{"lineNum":"   22","line":""},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 12, "covered" : 0,};
var merged_data = [];
