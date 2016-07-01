@echo OFF

if not exist %~dp0\3rd-party\NUL mkdir %~dp0\3rd-party
if not exist %~dp0\3rd-party\cygwin\NUL mkdir %~dp0\3rd-party\cygwin

call %~dp0\setup\install.bat

