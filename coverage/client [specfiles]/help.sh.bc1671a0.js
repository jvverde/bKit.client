var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"OS=\"$(uname -o |tr \'[:upper:]\' \'[:lower:]\')\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    3","line":"if [[ $OS == cygwin ]]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    4","line":"then"},
{"lineNum":"    5","line":"  ext=\'.bat\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":"else"},
{"lineNum":"    7","line":"  ext=\'.sh\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"  dot=\'./\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"fi"},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":"echo -e \"\\n\\nWellcome to bKit console. These are the available commands\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":"echo -e \"Just call a command with option --help to see the available options\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":"echo -e \"\\t${dot}bkit${ext}\\tBackup one or more directories or files\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":"echo -e \"\\t${dot}rkit${ext}\\tRestore one or more directories or files\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":"echo -e \"\\t${dot}skit${ext}\\tCreate a shadow copy first and then backup it (Requires Admin privileges on Windows).\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":"echo -e \"\\t${dot}dkit${ext}\\tShow whether directory differs from the last backup.\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   17","line":"echo -e \"\\t${dot}vkit${ext}\\tShow the backups versions of a given file.\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   18","line":"echo -e \"\\t${dot}help${ext}\\tTo see this message again.\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   19","line":"echo -e \"\\n\\n\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 14, "covered" : 0,};
var merged_data = [];
