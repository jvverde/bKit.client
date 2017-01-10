@echo OFF
set oldhome=%HOME%
set oldshell=%SHELL%
set oldpath=%path%
set path="%~dp03rd-party\cygwin\bin\bash.exe";%path%
set HOME=/home/user
set SHELL=/bin/bash
pushd "%~dp0"
call "%~dp03rd-party\cygwin\bin\bash.exe" %*
popd
set path=%oldpath%
set SHELL=%oldshell%
set HOME=%oldhome%
