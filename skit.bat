@echo OFF
set oldhome=%HOME%
set oldshell=%SHELL%
set oldpath=%path%
set path="%~dp03rd-party\cygwin\bin";%path%
set HOME=/home/user
set SHELL=/bin/bash
REM pushd "%~dp0"
"%~dp03rd-party\cygwin\bin\bash.exe" -c 'SDIR=$(cygpath -u "$1");"$SDIR/skit.sh" "${@:2}"' -- '%~dp0' %*
SET /a errno=%ERRORLEVEL%
REM popd
set path=%oldpath%
set SHELL=%oldshell%
set HOME=%oldhome%
exit /B %errno%
REM End
