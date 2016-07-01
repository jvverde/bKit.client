@echo OFF
:: http://stackoverflow.com/questions/5034076/what-does-dp0-mean-and-how-does-it-work
:: http://stackoverflow.com/questions/12322308/batch-file-to-check-64bit-or-32bit-os

reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OSARCH=32BIT || set OSARCH=64BIT

set MODULES=awk,rsync,perl
set ARGS= -B -R ..\3rd-party\cygwin -d -N -n -X -q -s http://mirrors.fe.up.pt/pub/cygwin/ -P %MODULES%

if %OSARCH%==32BIT ( 
	%~dp0\cygwin\setup-x86.exe %ARGS%
) else ( 
	%~dp0\cygwin\setup-x86_64.exe %ARGS%
)
