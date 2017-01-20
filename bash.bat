@echo OFF
set oldhome=%HOME%
set oldshell=%SHELL%
set oldpath=%path%
set path="%~dp03rd-party\cygwin\bin";%path%
set HOME=/home/user
set SHELL=/bin/bash
pushd "%~dp0"
"%~dp03rd-party\cygwin\bin\bash.exe" %*
SET /a errno=%ERRORLEVEL%
popd
set path=%oldpath%
set SHELL=%oldshell%
set HOME=%oldhome%
exit /B %errno%
