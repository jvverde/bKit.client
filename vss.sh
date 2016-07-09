#!/bin/bash
DRIVE=${1%%:*}
UFDIR=$(dirname "$(readlink -f "$0")")	#Unix Full DIR
WDIR=$(cygpath -w $UFDIR)				#Windows Full DIR
ARCHREG=$(CMD.EXE /C $WDIR\\get-arch-from-reg.bat)
[[ $ARCHREG = ~x86 ]] && ARCH=x86 || ARCH=x64 

VER=$(CMD.EXE /C VER)

[[ $VER == *"5.1."* ]] && VSSHADOW=vshadow-xp-x86
[[ $VER == *"5.2."* ]] && VSSHADOW=vshadow-2003-x86
[[ $VER == *"6.0."* ]] && VSSHADOW=vshadow-2008-$ARCH
[[ $VER == *"6.1."* ]] && VSSHADOW=vshadow-2008-r2-$ARCH

if [ $VSSHADOW ] 
then
	CMD /C $WDIR\\3rd-party\\vsshadow\\$VSSHADOW.exe -script=$WDIR\\run\\vss.cmd -exec=$WDIR\\backup.bat $DRIVE:
else
	echo 'something else'
fi
