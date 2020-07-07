var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"#Just check ih something exists"},
{"lineNum":"    3","line":"declare -F exists > /dev/null 2>&1 && [[ ! ${1+$1} =~ ^-f ]] && return","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    4","line":""},
{"lineNum":"    5","line":"exists() {"},
{"lineNum":"    6","line":"\ttype \"$1\" >/dev/null 2>&1;","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":"}"},
{"lineNum":"    8","line":""},
{"lineNum":"    9","line":"if [[ ${BASH_SOURCE[0]} == \"$0\" ]]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":"then"},
{"lineNum":"   11","line":"  echo \"The script \'$0\' is meant to be sourced\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":"  echo \"Usage: source \'$0\'\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":"fi"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 5, "covered" : 0,};
var merged_data = [];
