#!/bin/bash
# while getopts ":e:i" opt
# do
  # case $opt in
    # e) EXCLUDEFILE=${OPTARG}
    # ;;
    # i) INCLUDE=${OPTARG}
    # ;;
    # *) echo "Invalid option: -$OPTARG" && exit
    # ;;
  # esac
# done
# shift  $((OPTIND-1))

# if [ ! -z "$EXCLUDEFILE" ]
# then 
  # EXCLUDE=$( while read line 
  # do
    # F=${line//\ /?}
    # echo " -wholename \"*/$F\" -prune -o " 
  # done < $EXCLUDEFILE)
# fi

[ $# -le 0 ] && echo -e "Usage:\n\t$0 path [minutes]" && exit
BPATH="$(echo "$1" | sed -r 's#([a-z]):#/cygdrive/\1#i' | sed -r 's#\\+#/#g')"
MINUTES="$2"
[ ! -d "$BPATH" ] && echo "Path:$PATH does not exit" && exit
NEW=''
if [ ! -z "$MINUTES" ]
then
	NEW="-mmin -$MINUTES"
fi
FIND="$BPATH $EXCLUDE -not -empty -type f $NEW -print"
echo find $FIND
find $FIND #|xargs -0 --no-run-if-empty md5sum
