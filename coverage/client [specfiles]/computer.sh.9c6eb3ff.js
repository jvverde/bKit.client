var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"SDIR=$(dirname -- \"$(readlink -ne -- \"$0\")\")\t#Full SDIR","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    3","line":"source \"$SDIR/functions/all.sh\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    4","line":""},
{"lineNum":"    5","line":"exists wmic && {","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    6","line":"\tUUID=\"$(wmic csproduct get uuid /format:textvaluelist.xsl |tr -d \'\\r\'|sed -E \'/^$/d;s/^\\s+|\\s+$//;s/\\s+/_/g\'| awk -F \"=\" \'tolower($1) ~ /uuid/ {print $2}\')\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":"\tDOMAIN=\"$(wmic computersystem get domain /format:textvaluelist.xsl |tr -d \'\\r\'|sed -E \'/^$/d;s/^\\s+|\\s+$//;s/\\s+/_/g\' | awk -F \"=\" \'tolower($1) ~  /domain/ {print $2}\')\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    8","line":"\tNAME=\"$(wmic computersystem get name /format:textvaluelist.xsl |tr -d \'\\r\'|sed -E \'/^$/d;s/^\\s+|\\s+$//;s/\\s+/_/g\' | awk -F \"=\" \'tolower($1) ~  /name/ {print $2}\')\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"\techo \"${DOMAIN:-_}|${NAME:-_}|${UUID:-_}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":"} || {","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":"\tUUID=\"$(cat /var/lib/dbus/machine-id 2>/dev/null)\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":"\ttrue ${UUID:=\"$(cat /sys/devices/virtual/dmi/id/product_uuid 2>/dev/null)\"}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":"\ttrue ${UUID:=\"$(cat /sys/class/dmi/id/product_uuid 2>/dev/null)\"}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":"\ttrue ${UUID:=\"$(cat /sys/class/dmi/id/board_id 2>/dev/null)\"}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":"\ttrue ${UUID:=\"$(cat /etc/machine-id 2>/dev/null)\"}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":"\ttrue ${UUID:=\"$(dmidecode -s system-uuid 2>/dev/null)\"}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   17","line":"\ttrue ${UUID:=\"0000-0000\"}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   18","line":"\tDOMAIN=\"$(hostname -d)\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   19","line":"\ttrue ${DOMAIN:=local}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   20","line":"\tNAME=\"$(hostname -s)\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   21","line":"\ttrue ${NAME:=noname}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   22","line":"\techo \"${DOMAIN:-_}|${NAME:-_}|${UUID:-_}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   23","line":"}"},
{"lineNum":"   24","line":""},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 20, "covered" : 0,};
var merged_data = [];
