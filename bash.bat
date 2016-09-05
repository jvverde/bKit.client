@echo OFF
:: This file is automatically create by setup. Don't change it
set oldhome=%HOME%
set oldshell=%SHELL%
set oldpath=%path%
set path=D:\bkit\scripts\client\3rd-party\cygwin\bin\;%path%
set HOME=/home/user
set SHELL=/bin/bash
call D:\bkit\scripts\client\3rd-party\cygwin\bin\bash.exe %*
set path=%oldpath%
set SHELL=%oldshell%
set HOME=%oldhome%
