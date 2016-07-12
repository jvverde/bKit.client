@echo off
set SDIR=%~dp0
pushd .
cd %SDIR%
set DIR=%~f1
popd

%SDIR%3rd-party\shadowspawn\ShadowSpawn.exe c:\ B:\ %SDIR%bash.bat backup.sh %DIR% b:
