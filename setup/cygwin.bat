@echo OFF
:: http://stackoverflow.com/questions/5034076/what-does-dp0-mean-and-how-does-it-work
:: http://stackoverflow.com/questions/12322308/batch-file-to-check-64bit-or-32bit-os
Setlocal EnableDelayedExpansion

set wim="%cd%"

cd %~dp0

for %%i in ("%~dp0..") do set "PARENT=%%~fi"

set MODULES=awk,rsync,ping,nc,util-linux,perl,openssh,email,zip,unzip

reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | findstr /i "x86" > NUL && set OSARCH=32BIT || set OSARCH=64BIT

ver | findstr /IL "5.1." > NUL && set "VER=OLD"
ver | findstr /IL "5.2." > NUL && set "VER=OLD"
ver | findstr /IL "6.0." > NUL && set "VER=OLD"
if "%VER%"=="OLD" (
REM http://stackoverflow.com/questions/39479826/cygwin-2-5-2-mirror-getting-the-last-xp-release
REM http://www.fruitbat.org/Cygwin/timemachine.html
	set PARAMS= -B -R "%PARENT%\3rd-party\cygwin" -d -N -n -X -q -L -l "%~dp0\cygwin-old\repo" -P %MODULES%
	if %OSARCH%==32BIT (
		"%~dp0\cygwin-old\setup-x86-2.874.exe" !PARAMS!
	) else (
		"%~dp0\cygwin-old\setup-x86_64-2.874.exe" !PARAMS!
	)
) else (
	REM set PARAMS= -B -R "%PARENT%\3rd-party\cygwin" -d -N -n -X -q -L -l "%~dp0\cygwin\repo" -P %MODULES%
	set PARAMS= -B -R "%PARENT%\3rd-party\cygwin" -d -N -n -X -q -L -l "%~dp0\cygwin\repo" -P %MODULES%
	if %OSARCH%==32BIT (
		"%~dp0\cygwin\setup-x86.exe" !PARAMS!
	) else (
		"%~dp0\cygwin\setup-x86_64.exe" !PARAMS!
	)
)

cd %wim%
