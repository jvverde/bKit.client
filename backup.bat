@echo off
SETLOCAL
set SDIR=%~dp0
set DRIVE=%~d1

pushd .
cd %SDIR%
set DIR=%~f1
popd

if not exist %SDIR%logs\NUL mkdir %SDIR%logs

set CMD="%SDIR%3rd-party\cygwin\bin\bash.exe"
set SHSPW="%SDIR%3rd-party\shadowspawn\ShadowSpawn.exe"
set SUFFIX=%DIR::=_%
set SUFFIX=%SUFFIX:\=.%
set LOGFILE="%SDIR%logs\backup.bat.%SUFFIX%.log"


FSUTIL FSINFO VOLUMEINFO %DRIVE%\ | findstr /IC:"File System Name" | findstr /IL "NTFS" >NUL && set "NTFS=yes" || set "NTFS=no"
FSUTIL FSINFO DRIVETYPE %DRIVE% | findstr /IC:"Fixed Drive" >NUL && set "FIXED=yes" || set "FIXED=no"


for /f "tokens=*" %%a in ('FSUTIL FSINFO DRIVES') do set freedrv_drives=%%a

if %NTFS%==yes if %FIXED%==yes (
  for %%p in (E F G H I J K L M N O P Q R S T U V W X Y Z A B C D) do echo %freedrv_drives% | find /i "%%p:\" > nul || set LETTER=%%p:&& goto :HARDDRIVE
  goto :EOF
) 

echo Backup directly -- without shadow copy
%CMD% "%SDIR%backup.sh" '%DIR%' %DRIVE% >%LOGFILE% 2>&1
goto :EOF

:HARDDRIVE
echo Backup shadow copy
%SHSPW% /verbosity=4 %DRIVE%\ %LETTER% %CMD% "%SDIR%backup.sh" '%DIR%' %LETTER% >%LOGFILE% 2>&1 

:EOF