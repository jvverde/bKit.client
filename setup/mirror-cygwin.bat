@echo OFF
:: http://stackoverflow.com/questions/5034076/what-does-dp0-mean-and-how-does-it-work
:: http://stackoverflow.com/questions/12322308/batch-file-to-check-64bit-or-32bit-os
Setlocal EnableDelayedExpansion

set wim="%cd%"

cd %~dp0

for %%i in ("%~dp0..") do set "PARENT=%%~fi"

set MODULES=awk,rsync,ping,nc,util-linux,perl,openssh,email,zip,unzip

reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | findstr /i "x86" > NUL && set OSARCH=32BIT || set OSARCH=64BIT

set PARAMS= -B -D -d -N -n -X -q -l "%~dp0\cygwin\repo" -P %MODULES% -s http://www.mirrorservice.org/sites/sourceware.org/pub/cygwin/
if %OSARCH%==32BIT (
	"%~dp0\cygwin\setup-x86.exe" !PARAMS!
) else (
	"%~dp0\cygwin\setup-x86_64.exe" !PARAMS!
)
cd %wim%
