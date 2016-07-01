@echo OFF
SetLocal EnableDelayedExpansion
:: our path. The construction bellow avoid extra space see 
set "OP=%~dp0"
   

if not exist %OP%3rd-party\NUL mkdir %OP%3rd-party
if not exist %OP%3rd-party\cygwin\NUL mkdir %OP%3rd-party\cygwin

::call %OP%setup\install.bat
set bash=%OP%3rd-party\cygwin\bin\bash.exe
if not exist %bash% (
	echo try to find bash.exe as a last resource
	set wim=%cd%
	cd /D %OP%
	for /F "tokens=* USEBACKQ" %%B in ( `dir /B /S bash.exe` ) do (
		set bash=%%B
	)
	if not exist !bash! (
		echo unable to find bash.exe
	) else (
		echo bash.exe found here !bash!
	)
	cd /D %wim%
)
for %%F in ("%bash%") do set dirname=%%~dpF

>bash.bat echo ^@echo OFF
>>bash.bat echo set oldhome=%%HOME%%
>>bash.bat echo set oldshell=%%SHELL%%
>>bash.bat echo set oldpath=%%path%%
>>bash.bat echo set path=%dirname%;%%path%%
>>bash.bat echo set HOME=/home/user
>>bash.bat echo set SHELL=/bin/bash
>>bash.bat echo call %bash% %%*
>>bash.bat echo set path=%%oldpath%%
>>bash.bat echo set SHELL=%%oldshell%%
>>bash.bat echo set HOME=%%oldhome%%

