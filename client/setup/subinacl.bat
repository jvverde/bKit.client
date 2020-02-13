@echo OFF
setlocal
set "OP=%~dp0"
if not exist "%OP%..\3rd-party\subinacl\" mkdir "%OP%..\3rd-party\subinacl\"
copy /b /v /y "%OP%subinacl\subinacl.exe" "%OP%..\3rd-party\subinacl"
endlocal
