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

::call "%OP%setup\mirror-cygwin.bat"
::call "%OP%setup\cygwin.bat"
echo "Install Cygwin"
set cdir=%~dp0
set getCygwin=%cdir%setup\cygwin.ps1
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%getCygwin%'";

:: call "%OP%setup\shadowspawn.bat"
:: call "%OP%setup\subinacl.bat"
call "%OP%bash.bat" "%OP%\setup\setup.sh"
