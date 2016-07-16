@echo off
SETLOCAL
set SDIR=%~dp0

schtasks /CREATE /RU "SYSTEM" /SC MINUTE /MO 15 /TN BKIT /TR "%SDIR%backup.bat %1 >%SDIR%logs\task.log 2>%SDIR%logs\error.log"
:EOF