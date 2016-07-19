@echo off
SETLOCAL
set SDIR=%~dp0
set DIR=%1
set NAME=%DIR:\=.%
set NAME=%NAME::=_%
schtasks /CREATE /RU "SYSTEM" /SC MINUTE /MO 15 /TN "BKIT-%NAME%" /TR "%SDIR%backup.bat %DIR% >%SDIR%logs\task-%NAME%.log 2>%SDIR%logs\error-%NAME%.log"
:EOF