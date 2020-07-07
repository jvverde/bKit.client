var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"#https://dataprotector.onlinebackup.com/Help/TSK/bk_commonexcludes.html"},
{"lineNum":"    3","line":"SDIR=\"$(dirname -- \"$(readlink -f -- \"$0\")\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    4","line":"reg Query \"HKLM\\SYSTEM\\CurrentControlSet\\Control\\BackupRestore\\FilesNotToBackup\"|","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":"\tsed -nE \'/.*REG_MULTI_SZ\\s+(.+$)/{","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":"\t\ts//\\1/;","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":"\t\ts|\\\\0|\\n|g;","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"\t\ts|\\s*(/s)?$||mg;","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"\t\ts/%\\w+%/\\U&/g;","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":"\t\tp","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":"\t}\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 9, "covered" : 0,};
var merged_data = [];
