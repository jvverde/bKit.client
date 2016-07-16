@echo off
SETLOCAL
set SDIR=%~dp0
set DRIVE=%~d1

pushd .
cd %SDIR%
set DIR=%~f1
popd

FSUTIL FSINFO VOLUMEINFO %DRIVE%\ | findstr /IC:"File System Name" | findstr /IL "NTFS" >NUL && set "NTFS=yes" || set "NTFS=no"
FSUTIL FSINFO DRIVETYPE %DRIVE% | findstr /IC:"Fixed Drive" >NUL && set "FIXED=yes" || set "FIXED=no"


for /f "tokens=*" %%a in ('FSUTIL FSINFO DRIVES') do set freedrv_drives=%%a

if %NTFS%==yes if %FIXED%==yes (
  for %%p in (E F G H I J K L M N O P Q R S T U V W X Y Z A B C D) do echo %freedrv_drives% | find /i "%%p:\" > nul || set LETTER=%%p&& goto :HARDDRIVE
  goto :EOF
) 

echo backup directly -- without shadow copy
%SDIR%bash.bat %SDIR%backup.sh %DIR% %DRIVE%
goto :EOF

:HARDDRIVE
echo backup shadow copy
::%SDIR%3rd-party\shadowspawn\ShadowSpawn.exe %DRIVE%\ %LETTER%: %SDIR%bash.bat %SDIR%backup.sh %DIR% %LETTER%:
set CMD=C:\bkit\scripts\client\3rd-party\cygwin\bin\bash.exe
%SDIR%3rd-party\shadowspawn\ShadowSpawn.exe %DRIVE%\ %LETTER%: %CMD% "/cygdrive/c/bkit/scripts/client/backup.sh" %DIR% %LETTER%:

:EOF