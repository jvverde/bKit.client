var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"declare -r sdir=\"$(dirname -- \"$(readlink -ne -- \"${BASH_SOURCE[0]:-$0}\")\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"function usage(){"},
{"lineNum":"    5","line":"    local name=$(basename -s .sh \"$0\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":"    echo \"List bkit servers\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":"    echo -e \"Usage:\\n\\t $name\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"    exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"}"},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":"[[ $1 =~ ^--?h ]] && usage","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":""},
{"lineNum":"   13","line":"source \"$sdir/lib/functions/all.sh\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":""},
{"lineNum":"   15","line":"[[ ${ETCDIR+isset} == isset ]] || die \"ETCDIR is not defined\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":""},
{"lineNum":"   17","line":"declare -r CONFDIR=\"$ETCDIR/server\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   18","line":""},
{"lineNum":"   19","line":"find \"$CONFDIR\" -mindepth 1 -maxdepth 1 -type d -exec test -e \"{}/conf.init\" \';\' -printf \"%f\\n\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 10, "covered" : 0,};
var merged_data = [];
