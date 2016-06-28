#!/bin/bash
[ $# -le 0 ] && echo -e "Usage:\n\t$0 path [minutes]" && exit
BPATH="$1"
MINUTES="$2"
[ ! -d $BPATH ] && echo "Path:$PATH does not exit" && exit
NEW=''
if [ ! -z $MINUTES ]
then
	NEW="-mmin -$MINUTES"
fi
find $BPATH -not -empty -type f $NEW -print0 |xargs -0 --no-run-if-empty md5sum
