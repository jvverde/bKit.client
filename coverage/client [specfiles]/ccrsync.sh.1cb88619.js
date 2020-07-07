var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"#RSYNC Common Code"},
{"lineNum":"    3","line":"declare rccdir=\"$(dirname -- \"$(readlink -ne -- \"${BASH_SOURCE[0]}\")\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    4","line":"source \"$rccdir/lib/functions/all.sh\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":""},
{"lineNum":"    6","line":"[[ ${BKIT_CONFIG+isset} == isset && -e $BKIT_CONFIG ]] || {","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":"\tBKIT_CONFIG=\"$ETCDIR/server/default/conf.init\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"}"},
{"lineNum":"    9","line":""},
{"lineNum":"   10","line":"[[ -e $BKIT_CONFIG ]] || die \"Can\'t source file \'$BKIT_CONFIG\'\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":""},
{"lineNum":"   12","line":"source \"$BKIT_CONFIG\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":""},
{"lineNum":"   14","line":"[[ -e $PASSFILE ]] && export RSYNC_PASSWORD=\"$(<${PASSFILE})\" || die \"Pass file not found on location \'$PASSFILE\'\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":""},
{"lineNum":"   16","line":"[[ ${NOSSH+isset} == isset ]] && {","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   17","line":"\tunset RSYNC_CONNECT_PROG","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   18","line":"\tBACKUPURL=\"$RSYNCURL\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   19","line":"} || {","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   20","line":"\texport RSYNC_CONNECT_PROG=\"$SSH\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   21","line":"  BACKUPURL=\"$SSHURL\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   22","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 13, "covered" : 0,};
var merged_data = [];
