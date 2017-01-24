@echo off

if "%~1"=="" echo Usage: %0 program [arguments] && EXIT /B 1

NET SESSION>null 2>&1 && goto ADMINTASKS

:ELEVATE
pushd %~dp0
MSHTA "javascript: var shell = new ActiveXObject('shell.application'); shell.ShellExecute('%~nx0', '', '', 'runas', 1);close();"
EXIT /B

:ADMINTASKS
echo %*
pause
cmd /k %*
EXIT /B
