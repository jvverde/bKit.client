var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"SDIR=\"$(dirname -- \"$(readlink -en -- \"$0\")\")\"       #Full DIR","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    3","line":"source \"$SDIR/lib/functions/all.sh\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    4","line":"[[ -n $1 ]] || echo -e \"Usage:\\n\\t$0 VolumeId\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":"UUID=$1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":"exists fsutil && {","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":"  for DRV in $(fsutil fsinfo drives|sed \'s/\\r//g;s/\\\\//g\' |cut -d\' \' -f2-)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"  do"},
{"lineNum":"    9","line":"    fsutil fsinfo drivetype $DRV|grep -Piq \'Ram\\s+Disk\' && continue","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":"    fsutil fsinfo volumeinfo \"$DRV\\\\\"|grep -Piq \'^\\s*Volume\\s+Serial\\s+Number\\s*:\\s*0x\'$UUID\'\\s*$\' || continue","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":"    echo $DRV && exit 0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":"  done"},
{"lineNum":"   13","line":"  exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":"}"},
{"lineNum":"   15","line":""},
{"lineNum":"   16","line":"set -o pipefail","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   17","line":""},
{"lineNum":"   18","line":"bash \"$SDIR/getdev.sh\" \"$UUID\" |xargs -I{} df --output=target \"{}\"|tail -n 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 12, "covered" : 0,};
var merged_data = [];
