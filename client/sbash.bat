@echo OFF
set oldhome=%HOME%
set oldshell=%SHELL%
set oldpath=%path%
set path="%~dp03rd-party\cygwin\bin";%path%
set HOME=/home/%USERNAME%
set SHELL=/bin/bash
pushd "%~dp0"
"%~dp03rd-party\cygwin\bin\bash.exe" ./system.sh %*
SET /a errno=%ERRORLEVEL%
popd
set path=%oldpath%
set SHELL=%oldshell%
REM set HOME=%oldhome%
exit /B %errno%
REM End
