#!/bin/bash
UFDIR=$(dirname "$(readlink -f "$0")")	#Unix Full DIR
WDIR=$(cygpath -w $UFDIR)				#Windows Full DIR
ARCHREG=$(CMD.EXE /C $WDIR\\get-arch-from-reg.bat)
[[ $ARCHREG = ~x86 ]] && ARCH=x86 || ARCH=x64 
echo arch $ARCH
VER=$(CMD.EXE /C VER)
echo ver $VER
[[ $VER =~ "5\.1\." ]] && VSSHADOW=vshadow-xp-x86.exe
[[ $VER =~ "5\.2\." ]] && VSSHADOW=vshadow-2003-x86
[[ $VER =~ "6\.0\." ]] && VSSHADOW=vshadow-2008-$ARCH
[[ $VER =~ "6\.1\." ]] && VSSHADOW=vshadow-2008-r2-$ARCH
echo $VSSHADOW

# exit
# exit;
# set basedir=%~dp1
# set D=%basedir:~0,2%

# for /F %%V in ('VER') do set version=%%V
# echo %version%
# exit /b
# VER | FINDSTR /IL "5.1." > NUL
# IF %ERRORLEVEL% EQU 0 SET VSSHADOW=vshadow-xp-x86.exe
# VER | FINDSTR /IL "5.2." > NUL
# IF %ERRORLEVEL% EQU 0 SET VSSHADOW=vshadow-2003-x86
# VER | FINDSTR /IL "6.0." > NUL
# IF %ERRORLEVEL% EQU 0 SET VSSHADOW=vshadow-2008-OSARCH
# VER | FINDSTR /IL "6.1." > NUL
# IF %ERRORLEVEL% EQU 0 SET VSSHADOW=vshadow-2008-r2-OSARCH
# echo %VSSHADOW%