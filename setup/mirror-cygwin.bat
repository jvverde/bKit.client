@echo OFF
:: http://stackoverflow.com/questions/5034076/what-does-dp0-mean-and-how-does-it-work
:: http://stackoverflow.com/questions/12322308/batch-file-to-check-64bit-or-32bit-os
Setlocal EnableDelayedExpansion

set wim="%cd%"

cd %~dp0

for %%i in ("%~dp0..") do set "PARENT=%%~fi"

set MODULES=awk,rsync,ping,nc,util-linux,perl,openssh,email

reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | findstr /i "x86" > NUL && set OSARCH=32BIT || set OSARCH=64BIT

ver | findstr /IL "5.1." > NUL && set "VER=OLD"
ver | findstr /IL "5.2." > NUL && set "VER=OLD"
ver | findstr /IL "6.0." > NUL && set "VER=OLD"
if "%VER%"=="OLD" (
REM http://stackoverflow.com/questions/39479826/cygwin-2-5-2-mirror-getting-the-last-xp-release
REM http://www.fruitbat.org/Cygwin/timemachine.html
	if %OSARCH%==32BIT (
		set PARAMS= -B -D -d -N -n -X -q -l "%~dp0\cygwin-old\repo" -P %MODULES% -s ftp://www.fruitbat.org/pub/cygwin/circa/2016/08/30/104223
		"%~dp0\cygwin-old\setup-x86-2.874.exe" !PARAMS!
	) else (
		set PARAMS= -B -D -d -N -n -X -q -l "%~dp0\cygwin-old\repo" -P %MODULES% -s ftp://www.fruitbat.org/pub/cygwin/circa/64bit/2016/08/30/104235
		"%~dp0\cygwin-old\setup-x86_64-2.874.exe" !PARAMS!
	)
) else (
	set PARAMS= -B -D -d -N -n -X -q -l "%~dp0\cygwin\repo" -P %MODULES% -s http://www.pirbot.com/mirrors/cygwin/
	if %OSARCH%==32BIT (
		"%~dp0\cygwin\setup-x86.exe" !PARAMS!
	) else (
		"%~dp0\cygwin\setup-x86_64.exe" !PARAMS!
	)
)
cd %wim%
