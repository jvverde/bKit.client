@echo OFF
:: http://stackoverflow.com/questions/12206314/detect-if-visual-c-redistributable-for-visual-studio-2012-is-installed
:: http://stackoverflow.com/questions/21704041/creating-batch-script-to-unzip-a-file-without-additional-zip-tools
SETLOCAL
set SDIR=%~dp0
for %%i in ("%SDIR%..") do set "PARENT=%%~fi\"

pushd %cd%

cd /d %SDIR%
set "XP="
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | findstr /i "x86" > NUL && set "OSARCH=x86" || set "OSARCH=x64"
ver | findstr /IL "5.1." > NUL && set "XP=-XP"
set "SHADOW=%SDIR%shadowspawn\ShadowSpawn-0.2.2-%OSARCH%%XP%.zip"
echo unzip %SHADOW%
call :UnZipFile "%PARENT%3rd-party\shadowspawn" "%SHADOW%"

set "KEY=1D5E3C0FEDA1E123187686FED06E995A"
if %OSARCH%==x64 set "KEY=1926E8D15D0BCE53481466615F760A7F" 
set "STRING=HKLM\SOFTWARE\Classes\Installer\Products\%KEY%"
set "VCR=%SDIR%shadowspawn\vcredist-2010_%OSARCH%.exe"
reg Query %STRING% | findstr /IL "10.0.40219" > NUL || call "%VCR%"

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



