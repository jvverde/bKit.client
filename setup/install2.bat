@echo OFF
:: http://stackoverflow.com/questions/12206314/detect-if-visual-c-redistributable-for-visual-studio-2012-is-installed
:: http://stackoverflow.com/questions/21704041/creating-batch-script-to-unzip-a-file-without-additional-zip-tools

reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | findstr /i "x86" > NUL && set OSARCH=32BIT || set OSARCH=64BIT

if %OSARCH%==64BIT ( 
  reg Query "HKLM\SOFTWARE\Classes\Installer\Products\1926E8D15D0BCE53481466615F760A7F" |findstr /i "10.0.40219" > NUL && set VCR=YES
  if %VCR%==YES ( echo yes1 )
) else ( 
  reg Query "HKLM\SOFTWARE\Classes\Installer\Products\1D5E3C0FEDA1E123187686FED06E995A" |findstr /i "10.0.40219" > NUL && set VCR=YES
  if %VCR%==YES ( echo yes2 )
)


