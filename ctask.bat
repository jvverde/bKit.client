@echo off
setlocal
set "SDIR=%~dp0"
set "ARG=%1"
if "%ARG%"=="" echo Usage: ctask dirname && exit /b
if "%ARG:~-1%"==":" (set "DIR=%ARG%\") else (set DIR=%~f1)
set NAME=%DIR:\=-%
set NAME=%NAME::=%
if "%NAME:~-1%"=="-" set "NAME=%NAME:~0,-1%"
schtasks /CREATE /RU "SYSTEM" /SC MINUTE /MO 15 /TN "BKIT_%NAME%" /TR ""%SDIR%backup.bat" "%DIR%"" >"%SDIR%logs\task-%NAME%.log" 2>&1
:EOF