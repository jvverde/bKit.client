var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"set -u","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    3","line":"declare -r sdir=$(dirname -- \"$(readlink -en -- \"$0\")\")\t#Full sdir","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    4","line":"source \"$sdir/lib/functions/all.sh\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":""},
{"lineNum":"    6","line":"usage() {"},
{"lineNum":"    7","line":"\tbash \"$sdir/restore.sh\" --help=\"$(basename -s .sh -- \"$0\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"\texit 1;","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"}"},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":"declare -a options=()","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":"declare -a rsyncoptions=()","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":""},
{"lineNum":"   14","line":"while [[ ${1:-} =~ ^- ]]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":"do"},
{"lineNum":"   16","line":"\tkey=\"$1\" && shift","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   17","line":"\tcase \"$key\" in","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   18","line":"\t\t-- )"},
{"lineNum":"   19","line":"\t\t\twhile [[ $1 =~ ^- ]]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   20","line":"\t\t\tdo"},
{"lineNum":"   21","line":"\t\t\t\trsyncoptions+=( \"$1\" )","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   22","line":"\t\t\t\tshift","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   23","line":"\t\t\tdone"},
{"lineNum":"   24","line":"\t\t;;"},
{"lineNum":"   25","line":"\t\t-h|--help)"},
{"lineNum":"   26","line":"\t\t\tusage","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   27","line":"\t\t;;"},
{"lineNum":"   28","line":"\t\t*)"},
{"lineNum":"   29","line":"\t\t\toptions+=( \"$key\" )","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   30","line":"\t\t;;"},
{"lineNum":"   31","line":"\tesac"},
{"lineNum":"   32","line":"done"},
{"lineNum":"   33","line":""},
{"lineNum":"   34","line":"(( $# == 0 )) && usage","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   35","line":""},
{"lineNum":"   36","line":"declare -r pgid=\"$(cat /proc/self/pgid 2>/dev/null)\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   37","line":"echo \"rKit[$$:$pgid]: Start Restore for ${@:-.}\" #Don\'t chand this format. It is used by GUI","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   38","line":""},
{"lineNum":"   39","line":"if exists cygpath","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   40","line":"then"},
{"lineNum":"   41","line":"\tdeclare -a args=()","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   42","line":"\tfor arg in \"${@:-.}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   43","line":"\tdo"},
{"lineNum":"   44","line":"\t\t# arg=\"$(echo $arg|perl -lape \'s/^\"(.+)\"$/$1/\')\" #This is a workaround to remove extra quotes introduced my cmd.exe"},
{"lineNum":"   45","line":"\t  args+=( \"$(cygpath -u \"$arg\")\" )","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   46","line":"\tdone"},
{"lineNum":"   47","line":"else"},
{"lineNum":"   48","line":"\tdeclare -ra args=(\"${@:-.}\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   49","line":"fi"},
{"lineNum":"   50","line":""},
{"lineNum":"   51","line":"bash \"$sdir/restore.sh\" ${options+\"${options[@]}\"} -- --filter=\": .rsync-filter\" ${rsyncoptions+\"${rsyncoptions[@]}\"} \"${args[@]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   52","line":"echo \"rKit[$$:$pgid]: Done\" #Don\'t chand this format. It is used by GUI","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 25, "covered" : 0,};
var merged_data = [];
