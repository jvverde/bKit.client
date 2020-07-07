var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"sdir=$(dirname -- \"$(readlink -en -- \"$0\")\")  #Full sdir","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    3","line":"source \"$sdir/../functions/all.sh\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    4","line":""},
{"lineNum":"    5","line":"exists wmic && {","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":"  wmic logicalDisk Where DriveType!=\'6\' Get name|tail -n +2| sed \'s/\\r//g\'| sed \'/^[[:space:]]*$/d\'| sed \'s#[[:space:]]*$#\\\\#\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":"  exit 0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"}"},
{"lineNum":"    9","line":"exists fsutil && {","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":"  for DRV in $(fsutil fsinfo drives| tr -d \'\\r\' | sed /^$/d | cut -d\' \' -f2-)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":"  do"},
{"lineNum":"   12","line":"    fsutil fsinfo drivetype $DRV|grep -Piq \'Ram\\s+Disk\' && continue","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":"    echo $DRV","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":"  done"},
{"lineNum":"   15","line":"  exit 0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":"}"},
{"lineNum":"   17","line":"exists df && {","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   18","line":"  df --output=target -x tmpfs -x devtmpfs |tail -n +2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   19","line":"  exit 0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   20","line":"}"},
{"lineNum":"   21","line":"die \"neither found fsutil nor df\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 14, "covered" : 0,};
var merged_data = [];
