@echo off
::http://stackoverflow.com/a/15494791
::http://stackoverflow.com/questions/14338691/passing-parameters-by-reference-between-scripts
::http://stackoverflow.com/questions/10518151/how-to-check-in-command-line-if-a-given-file-or-directory-is-locked-used-by-any

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

call :checkfile LOGFILE
call :checkfile LOGFILE2

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


:checkfile ::check if the file in use by another proccess
  setlocal enableDelayedExpansion
  ::call set file=%%%~1%% alternative to enableDelayedExpansion
  set file=!%~1!
  call :findfile %file% return
  endlocal & set "%~1="%return%""
  exit /b
  
:findfile ::find a file not used by any other process
  setlocal
  set "file=%~1"
  set /a c=0
  :until
  2>nul (
    >>"%file%" echo off
  ) || set /a c=1+%c% && set "file=%file%.%c%" && goto :until
  endlocal & set "%~2=%file%"
  exit /b
  
