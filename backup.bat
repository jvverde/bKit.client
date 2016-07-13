@echo off
SETLOCAL
set SDIR=%~dp0
set DRIVE=%~d1
pushd .
cd %SDIR%
set DIR=%~f1
popd

for /f "tokens=*" %%a in ('FSUTIL FSINFO DRIVES') do set freedrv_drives=%%a
for %%p in (E F G H I J K L M N O P Q R S T U V W X Y Z A B C D) do echo %freedrv_drives% | find /i "%%p:\" > nul || set LETTER=%%p&& goto :FOUND


:FOUND

%SDIR%3rd-party\shadowspawn\ShadowSpawn.exe %DRIVE%\ %LETTER%: %SDIR%bash.bat %SDIR%backup.sh %DIR% %LETTER%:
