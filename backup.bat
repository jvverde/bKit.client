@echo off
set SDIR=%~dp0
pushd .
cd %SDIR%
set DIR=%~f1
popd

for %%p in (b c d e f g h i j k l m n o p q r s t u v w x y z) do (
  if not exist %%p:\nul (
    set LETTER=%%p:
    goto :CONTINE
  )
)
:CONTINE
echo %LETTER%
exit /b

%SDIR%3rd-party\shadowspawn\ShadowSpawn.exe c:\ B: %SDIR%bash.bat %SDIR%backup.sh %DIR% b:
