@echo OFF
:: http://stackoverflow.com/questions/5034076/what-does-dp0-mean-and-how-does-it-work
:: http://stackoverflow.com/questions/12322308/batch-file-to-check-64bit-or-32bit-os

set wim="%cd%"

cd %~dp0

for %%i in ("%~dp0..") do set "PARENT=%%~fi"

set MODULES=awk,rsync,xargs,ping,nc,util-linux,ntfsprogs,sqlite3

set ARGS= -B -R %PARENT%\3rd-party\cygwin -d -N -n -X -q -s http://ftp.snt.utwente.nl/pub/software/cygwin/ -P %MODULES%

reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | findstr /i "x86" > NUL && set OSARCH=32BIT || set OSARCH=64BIT

#ver | findstr /IL "5.1." > NUL && set "XP=XP"

if %OSARCH%==32BIT ( 
	%~dp0\cygwin\setup-x86.exe %ARGS%
) else ( 
	%~dp0\cygwin\setup-x86_64.exe %ARGS%
)

cd %wim%