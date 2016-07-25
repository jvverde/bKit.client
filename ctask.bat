@echo off
set SDIR=%~dp0
set DIR=%~f1
echo 1: %1
echo *: %*
if "%DIR%"=="" echo Usage: ctask dirname && exit /b
if %DIR:~-1%==\ set DIR=%DIR:~0,-1%
set NAME=%DIR:\=-%
set NAME=%NAME::=%
echo dir = %DIR%
exit /b
schtasks /CREATE /RU "SYSTEM" /SC MINUTE /MO 15 /TN "BKIT_%NAME%" /TR "%SDIR%backup.bat" "%DIR%" >"%SDIR%logs\task-%NAME%.log" 2>&1
:EOF