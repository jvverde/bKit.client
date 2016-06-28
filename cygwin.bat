@echo off

set drive=%~dp0

set drivep=%drive%
if #%drive:~-1%# == #\# set drivep=%drive:~0,-1%

set NEWPATH=%drivep%\3rd-party\CygwinPortable\App\Runtime\Cygwin\bin
if not exist %NEWPATH% goto :NOTPATH
call set "OLDPATH=%%PATH:%NEWPATH%=%%"
if "%OLDPATH%"=="%PATH%" set PATH=%NEWPATH%;%PATH%

REM cmd /K

exit /b

:NOTPATH
echo %NEWPATH% not exists

