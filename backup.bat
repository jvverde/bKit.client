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
set LOGFILE2="%SDIR%logs\backup.sh.%SUFFIX%.log"

echo logfile begore %LOGFILE%
echo logfile2 begore %LOGFILE2%
call :busy LOGFILE
call :busy LOGFILE2
echo ----------
echo logfile after %LOGFILE%
echo logfile2 after %LOGFILE2%
exit /b
FSUTIL FSINFO VOLUMEINFO %DRIVE%\ | findstr /IC:"File System Name" | findstr /IL "NTFS" >NUL && set "NTFS=yes" || set "NTFS=no"
FSUTIL FSINFO DRIVETYPE %DRIVE% | findstr /IC:"Fixed Drive" >NUL && set "FIXED=yes" || set "FIXED=no"


for /f "tokens=*" %%a in ('FSUTIL FSINFO DRIVES') do set freedrv_drives=%%a

if %NTFS%==yes if %FIXED%==yes (
  for %%p in (E F G H I J K L M N O P Q R S T U V W X Y Z A B C D) do echo %freedrv_drives% | find /i "%%p:\" > nul || set LETTER=%%p:&& goto :HARDDRIVE
  goto :EOF
) 

echo Backup directly -- without shadow copy
%CMD% "%SDIR%backup.sh" '%DIR%' %DRIVE% 
::>>%LOGFILE% 2>&1 
::& type %LOGFILE%
goto :EOF

:HARDDRIVE
echo Backup shadow copy
%SHSPW% /verbosity=4 %DRIVE%\ %LETTER% %CMD% "%SDIR%backup.sh" -log %LOGFILE2% '%DIR%' %LETTER% >%LOGFILE% 2>&1 & type %LOGFILE%

:EOF
exit /b


:busy
  setlocal enableDelayedExpansion
  echo ---------------
  echo %~1=!%~1!
 echo 1: %1 
 set file=!%~1!
 echo file init: !file!
 :WHILE
  2>nul (
    >>!file! echo off
  ) && goto :CONT
  set file=!file!0
  echo file: !file!
  goto :WHILE
:CONT 
  echo file end: !file!
 set "%~1=!file!"
 echo %~1=!%~1!
 exit /b
