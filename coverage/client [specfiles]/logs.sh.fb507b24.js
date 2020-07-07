var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"#Defines a functio to redirect stdout and stderr to given dir"},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"redirectlogs() {"},
{"lineNum":"    5","line":"\tlocal logdir=$(readlink -nm \"$1\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":"\tlocal prefix=\"${2:+$2-}\"\t\t\t\t#if second argument is set use it immediately follwed by a hyphen as a prefix. Otherwise prefix will be empty","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":"\t[[ -d $logdir ]] || mkdir -pv \"$logdir\" || die \"Can\'t mkdir $logdir\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"\tlocal now=$(date +%Y-%m-%dT%H-%M-%S)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"\tlocal logfile=\"$logdir/${prefix}log-$now\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":"\tlocal errfile=\"$logdir/${prefix}err-$now\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":"\t:> \"$logfile\"\t\t\t\t\t\t#create/truncate log file","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":"\t:> \"$errfile\"\t\t\t\t\t\t#create/truncate err file","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":"\techo \"Logs go to $logfile\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":"\techo \"Errors go to $errfile\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":"\texec 1>\"$logfile\"\t\t\t\t\t#fork stdout to logfile","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":"\texec 2>\"$errfile\"\t\t\t\t\t#fork stderr to errfile","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   17","line":"}"},
{"lineNum":"   18","line":""},
{"lineNum":"   19","line":"if [[ ${BASH_SOURCE[0]} == \"$0\" ]]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   20","line":"then"},
{"lineNum":"   21","line":"  echo \"The script \'$0\' is meant to be sourced\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   22","line":"  echo \"Usage: source \'$0\'\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   23","line":"fi"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 15, "covered" : 0,};
var merged_data = [];
