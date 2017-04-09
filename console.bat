@echo OFF
set path="%~dp0";%path%
set "TAB=   "
echo Wellcome to bKit console. These are the available commands
echo Just call a command without arguments to see the available options
echo %TAB%- bkit: Backup one or more directories or files
echo %TAB%- rkit: Restore one or more directories or files
echo %TAB%- skit: Like bkit, but create a shadow copy first and then backup it
echo %TAB%- dkit: Show whether directory differs from the last backup
echo %TAB%- vkit: Show the backups versions of a given directory or file.
echo.
PUSHD "%UserProfile%\"
CMD /T:80 /K
POPD
COLOR
EXIT /b
