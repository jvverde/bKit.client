@echo OFF
:: http://stackoverflow.com/questions/12206314/detect-if-visual-c-redistributable-for-visual-studio-2012-is-installed
:: http://stackoverflow.com/questions/21704041/creating-batch-script-to-unzip-a-file-without-additional-zip-tools
SETLOCAL
set SDIR=%~dp0
for %%i in ("%SDIR%..") do set "PARENT=%%~fi\"

pushd %cd%

cd /d %SDIR%
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | findstr /i "x86" > NUL && set OSARCH=32BIT || set OSARCH=64BIT

if %OSARCH%==64BIT ( 
  reg Query "HKLM\SOFTWARE\Classes\Installer\Products\1926E8D15D0BCE53481466615F760A7F" |findstr /i "10.0.40219" > NUL || set VCR=NO
  if %VCR%==NO ( 
    call %SDIR%shadowspawn\vcredist-2010_x64.exe
  )
  call :UnZipFile "%PARENT%3rd-party\shadowspawn" "%SDIR%shadowspawn\ShadowSpawn-0.2.2-x64.zip"
) else ( 
  reg Query "HKLM\SOFTWARE\Classes\Installer\Products\1D5E3C0FEDA1E123187686FED06E995A" |findstr /i "10.0.40219" > NUL || set VCR=NO
  if %VCR%==NO ( 
    call %SDIR%shadowspawn\vcredist-2010_x86.exe
  )
  call :UnZipFile "%PARENT%3rd-party\shadowspawn" "%SDIR%shadowspawn\ShadowSpawn-0.2.2-x86.zip"
)

popd
exit /b

:UnZipFile <ExtractTo> <newzipfile>
set vbs="%SDIR%\copyzip.vbs"
if exist %vbs% del /f /q %vbs%
>%vbs%  echo Set fso = CreateObject("Scripting.FileSystemObject")
>>%vbs% echo If NOT fso.FolderExists(%1) Then
>>%vbs% echo fso.CreateFolder(%1)
>>%vbs% echo End If
>>%vbs% echo set objShell = CreateObject("Shell.Application")
>>%vbs% echo set FilesInZip=objShell.NameSpace(%2).items
>>%vbs% echo objShell.NameSpace(%1).CopyHere FilesInZip, 16
>>%vbs% echo Set fso = Nothing
>>%vbs% echo Set objShell = Nothing
cscript //nologo %vbs%
if exist %vbs% del /f /q %vbs%
