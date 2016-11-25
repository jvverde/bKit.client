@echo off

if "%~1"=="" echo Usage: %0 program [arguments] && exit /b 1

:checkPrivileges
net session>null 2>&1 && goto gotPrivileges || goto getPrivileges

:getPrivileges
setlocal ENABLEDELAYEDEXPANSION
set "batchPath=%~0"
set batchName=%~n1
set "vbsGetPrivileges=%~dp0\run\OEgetPriv_%batchName%.vbs"

set "ARGS=%*"
set "ARGS=!ARGS:*%1=!"
set "ARGS=!ARGS:"=""!"
set "script=""%~f1"""

> "%vbsGetPrivileges%" (
  echo Set UAC = CreateObject^("Shell.Application"^)
  echo args = "/K ""%script% %ARGS%"""
  echo UAC.ShellExecute "cmd", args, "", "runas", 1
)
"%SystemRoot%\System32\WScript.exe" "%vbsGetPrivileges%"
exit /B

:gotPrivileges
setlocal & pushd .
cd /d %~dp0
cmd /c %*