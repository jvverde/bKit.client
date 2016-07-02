@echo off
set basedir=%~dp1
set D=%basedir:~0,2%

for /F %%V in ('VER') do set version=%%V
echo %version%
exit /b
VER | FINDSTR /IL "5.1." > NUL
IF %ERRORLEVEL% EQU 0 SET VSSHADOW=vshadow-xp-x86.exe
VER | FINDSTR /IL "5.2." > NUL
IF %ERRORLEVEL% EQU 0 SET VSSHADOW=vshadow-2003-x86
VER | FINDSTR /IL "6.0." > NUL
IF %ERRORLEVEL% EQU 0 SET VSSHADOW=vshadow-2008-OSARCH
VER | FINDSTR /IL "6.1." > NUL
IF %ERRORLEVEL% EQU 0 SET VSSHADOW=vshadow-2008-r2-OSARCH
echo %VSSHADOW%