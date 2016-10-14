@echo OFF
:: http://stackoverflow.com/questions/12322308/batch-file-to-check-64bit-or-32bit-os
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" 
::| find /i "x86" > NUL && set OSARCH=32BIT || set OSARCH=64BIT

::if %OSARCH%==32BIT echo This is a 32bit operating system
::if %OSARCH%==64BIT echo This is a 64bit operating system
