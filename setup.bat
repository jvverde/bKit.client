@echo OFF
SetLocal EnableDelayedExpansion
:: our path. The construction bellow avoid extra space see 
set "OP=%~dp0"
   

if not exist "%OP%conf\" mkdir "%OP%conf"
if not exist "%OP%logs\" mkdir "%OP%logs"
if not exist "%OP%cache\" mkdir "%OP%cache"
if not exist "%OP%run\" mkdir "%OP%run"
if not exist "%OP%3rd-party\" mkdir "%OP%3rd-party"
if not exist "%OP%3rd-party\cygwin\" mkdir "%OP%3rd-party\cygwin"
if not exist "%OP%3rd-party\shadowspawn\" mkdir "%OP%3rd-party\shadowspawn"
if not exist "%OP%run\" mkdir "%OP%run"
if not exist "%OP%cache\" mkdir "%OP%cache"

call "%OP%setup\subinacl.bat"
call "%OP%setup\cygwin.bat"
call "%OP%setup\shadowspawn.bat"

set bash=%OP%3rd-party\cygwin\bin\bash.exe
if not exist "%bash%" (
	echo bash.exe not found 
	exit /b
)
for %%F in ("%bash%") do set dirname=%%~dpF

>"%OP%bash.bat" (
  echo ^@echo OFF
  echo :: This file is automatically create by %0. Don't change it
  echo set oldhome=%%HOME%%
  echo set oldshell=%%SHELL%%
  echo set oldpath=%%path%%
  echo set path="%dirname%";%%path%%
  echo set HOME=/home/user
  echo set SHELL=/bin/bash
  echo call "%bash%" %%*
  echo set path=%%oldpath%%
  echo set SHELL=%%oldshell%%
  echo set HOME=%%oldhome%%
)
call "%OP%bash.bat" "%OP%setup.sh"
