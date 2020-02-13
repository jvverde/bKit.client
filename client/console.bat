@echo OFF
set path="%~dp0";%path%
call help.bat
PUSHD "%UserProfile%\"
CMD /T:80 /K
POPD
COLOR
EXIT /b
