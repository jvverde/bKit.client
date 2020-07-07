var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"SDIR=\"$(dirname -- \"$(readlink -ne -- \"$0\")\")\"                          #Full DIR","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"source \"$SDIR/functions/all.sh\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    5","line":""},
{"lineNum":"    6","line":"DIR=\"$(readlink -ne -- \"$1\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    7","line":""},
{"lineNum":"    8","line":"MOUNT=$(stat -c%m \"$DIR\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"#Find the top most mount point. We need this for example for BTRFS subvolumes which are mounting points"},
{"lineNum":"   10","line":"MOUNT=\"$(echo \"$MOUNT\" |fgrep -of <(df --sync --output=target |tail -n +2|sort -r)|head -n1)\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":""},
{"lineNum":"   12","line":"[[ -b $DIR ]] && DEV=\"$DIR\" || {","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":"\texists cygpath && DIR=$(cygpath \"$DIR\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":"\tDEV=$(df --output=source \"$MOUNT\"|tail -1)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":"}"},
{"lineNum":"   16","line":""},
{"lineNum":"   17","line":"[[ -b $DEV ]] || {","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   18","line":"\t#echo try another way >&2"},
{"lineNum":"   19","line":"\texists lsblk && DEV=\"$(lsblk -ln -oNAME,MOUNTPOINT |awk -v m=\"$MOUNT\" \'$2 == m {printf(\"/dev/%s\",$1)}\')\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   20","line":"}"},
{"lineNum":"   21","line":""},
{"lineNum":"   22","line":"[[ $OS == cygwin ]] && exists wmic && {","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   23","line":"\tDRIVE=${DEV%%:*} #just left drive letter, nothing else","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   24","line":"\tLD=\"$(WMIC logicaldisk WHERE \"name like \'$DRIVE:\'\" GET VolumeName,FileSystem,VolumeSerialNumber,drivetype /format:textvaluelist|","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   25","line":"\t\ttr -d \'\\r\'|","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   26","line":"\t\tsed -r \'/^$/d;s/^\\s+|\\s+$//;s/\\s+/_/g\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   27","line":"\t)\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   28","line":""},
{"lineNum":"   29","line":"\tFS=$(awk -F \'=\' \'tolower($1) ~  /filesystem/ {print $2}\' <<<\"$LD\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   30","line":"\tVN=$(awk -F \'=\' \'tolower($1) ~  /volumename/ {print $2}\' <<<\"$LD\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   31","line":"\tSN=$(awk -F \'=\' \'tolower($1) ~  /volumeserialnumber/ {print $2}\' <<<\"$LD\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   32","line":"\tDT=$(awk -F \'=\' \'tolower($1) ~  /drivetype/ {print $2}\' <<<\"$LD\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   33","line":"\techo \"${VN:-_}|${SN:-_}|${FS:-_}|${DT:-_}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   34","line":"\texit","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   35","line":"}"},
{"lineNum":"   36","line":""},
{"lineNum":"   37","line":"[[ $OS == cygwin ]] && exists fsutil && {","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   38","line":"\tDRIVE=${DEV%%:*} #just left drive letter, nothing else","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   39","line":"\tVOLUMEINFO=\"$(fsutil fsinfo volumeinfo $DRIVE:\\\\ | tr -d \'\\r\')\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   40","line":"\tVOLUMENAME=$(echo -e \"$VOLUMEINFO\"| awk -F \":\" \'toupper($1) ~ /VOLUME NAME/ {print $2}\' |","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   41","line":"\t\tsed -E \'s/^\\s*//;s/\\s*$//;s/[^a-z0-9]/-/gi;s/^$/_/;s/\\s/_/g\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   42","line":"\t)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   43","line":"\tVOLUMESERIALNUMBER=$(echo -e \"$VOLUMEINFO\"| awk -F \":\" \'toupper($1) ~ /VOLUME SERIAL NUMBER/ {print toupper($2)}\' |","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   44","line":"\t\tsed -E \'s/^\\s*//;s/\\s*$//;s/^0x//gi;s/^$/_/;s/\\s/_/g\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   45","line":"\t)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   46","line":"\tFILESYSTEM=$(echo -e \"$VOLUMEINFO\"| awk -F \":\" \'toupper($1) ~ /FILE SYSTEM NAME/ {print $2}\' |","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   47","line":"\t\tsed -E \'s/^\\s*//;s/\\s*$//;s/^0x//gi;s/^$/_/;s/\\s/_/g\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   48","line":"\t)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   49","line":"\tDRIVETYPE=$(fsutil fsinfo driveType $DRIVE: | tr -d \'\\r\'|","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   50","line":"\t\tsed -e \"s/^$DRIVE:.*- *//\" | sed -E \'s/[^a-z0-9]/-/gi;s/^$/_/;s/\\s/_/g\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   51","line":"\t)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   52","line":"\techo \"$VOLUMENAME|$VOLUMESERIALNUMBER|$FILESYSTEM|$DRIVETYPE\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   53","line":"\texit","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   54","line":"} 2>/dev/null","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   55","line":""},
{"lineNum":"   56","line":"readNameBy() {"},
{"lineNum":"   57","line":"\t\tlocal device=\"$(readlink -ne -- \"$DEV\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   58","line":"\t\tRESULT=$(find /dev/disk/by-id -lname \"*/${device##*/}\" -print|sort|head -n1 )","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   59","line":"\t\tRESULT=${RESULT##*/}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   60","line":"\t\tRESULT=${RESULT%-*}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   61","line":"\t\tVOLUMENAME=${RESULT#*-}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   62","line":"}"},
{"lineNum":"   63","line":""},
{"lineNum":"   64","line":"readTypeBy() {"},
{"lineNum":"   65","line":"\t\tlocal device=\"$(readlink -ne -- \"$DEV\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   66","line":"\t\tRESULT=$(find /dev/disk/by-id -lname \"*/${device##*/}\" -print|sort|head -n1 )","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   67","line":"\t\tRESULT=${RESULT##*/}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   68","line":"\t\tDRIVETYPE=${RESULT%%-*}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   69","line":"}"},
{"lineNum":"   70","line":""},
{"lineNum":"   71","line":"readUUIDby() {"},
{"lineNum":"   72","line":"\tfor U in $(ls /dev/disk/by-uuid)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   73","line":"\tdo"},
{"lineNum":"   74","line":"\t\t[[ \"$(readlink -ne -- \"$DEV\")\" == \"$(readlink -ne -- \"/dev/disk/by-uuid/$U\")\" ]] && VOLUMESERIALNUMBER=\"$U\" && return","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   75","line":"\tdone"},
{"lineNum":"   76","line":"}"},
{"lineNum":"   77","line":""},
{"lineNum":"   78","line":"readIDby() {"},
{"lineNum":"   79","line":"\tfor U in $(ls /dev/disk/by-id)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   80","line":"\tdo"},
{"lineNum":"   81","line":"\t\t[[ \"$(readlink -ne -- \"$DEV\")\" == \"$(readlink -ne \"/dev/disk/by-id/$U\")\" ]] && VOLUMESERIALNUMBER=\"${U//[^0-9A-Za-z_-]/_}\" && return","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   82","line":"\tdone"},
{"lineNum":"   83","line":"}"},
{"lineNum":"   84","line":""},
{"lineNum":"   85","line":"volume() {"},
{"lineNum":"   86","line":"\texists lsblk && {","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   87","line":"\t\tVOLUMENAME=\"$(lsblk -ln -o LABEL \"$DEV\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   88","line":"\t\ttrue ${VOLUMENAME:=$(lsblk -ln -o PARTLABEL $DEV)}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   89","line":"\t\ttrue ${VOLUMENAME:=$(lsblk -ln -o VENDOR,MODEL ${DEV%%[0-9]*})}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   90","line":"\t\ttrue ${VOLUMENAME:=$(lsblk -ln -o MODEL ${DEV%%[0-9]*})}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   91","line":"\t\ttrue ${FILESYSTEM:=\"$(lsblk -ln -o FSTYPE \"$DEV\")\"}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   92","line":"\t\tDRIVETYPE=$(lsblk -ln -o TRAN ${DEV%%[0-9]*})","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   93","line":"\t\tVOLUMESERIALNUMBER=$(lsblk -ln -o UUID $DEV)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   94","line":"\t}"},
{"lineNum":"   95","line":"\texists blkid  && {","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   96","line":"\t\ttrue ${FILESYSTEM:=$(blkid \"$DEV\" |sed -E \'s#.*TYPE=\"([^\"]+)\".*#\\1#\')}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   97","line":"\t\ttrue ${VOLUMESERIALNUMBER:=$(blkid \"$DEV\" |fgrep \'UUID=\' | sed -E \'s#.*UUID=\"([^\"]+)\".*#\\1#\')}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   98","line":"\t}"},
{"lineNum":"   99","line":""},
{"lineNum":"  100","line":"\t[[ -n $DRIVETYPE ]] || readTypeBy","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  101","line":"\t[[ -n $VOLUMESERIALNUMBER ]] || readUUIDby","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  102","line":"\t[[ -n $VOLUMESERIALNUMBER ]] || readIDby","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  103","line":"\t[[ -n $VOLUMENAME ]] || readNameBy","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  104","line":""},
{"lineNum":"  105","line":"\ttrue ${FILESYSTEM:=\"$(df --output=fstype \"$DEV\"|tail -n1)\"}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  106","line":""},
{"lineNum":"  107","line":"\ttrue ${DRIVETYPE:=_}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  108","line":"\ttrue ${VOLUMESERIALNUMBER:=_}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  109","line":"\ttrue ${VOLUMENAME:=_}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  110","line":"\ttrue ${FILESYSTEM:=_}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  111","line":""},
{"lineNum":"  112","line":"\tVOLUMENAME=$(echo $VOLUMENAME| sed -E \'s/\\s+/_/g\')","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  113","line":"}"},
{"lineNum":"  114","line":""},
{"lineNum":"  115","line":""},
{"lineNum":"  116","line":"[[ $OS != cygwin ]] && {","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  117","line":"\tvolume","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  118","line":"\techo \"$VOLUMENAME|$VOLUMESERIALNUMBER|$FILESYSTEM|$DRIVETYPE\" | perl -lape \'s/[^a-z0-9._|:+=-]/_/ig\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  119","line":"\texit","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  120","line":"} 2>/dev/null","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  121","line":""},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "shellspec spec", "date" : "2020-07-07 12:21:07", "instrumented" : 79, "covered" : 0,};
var merged_data = [];
