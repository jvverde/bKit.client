@echo OFF
pushd "%~dp0"
"%~dp03rd-party\cygwin\bin\bash.exe" ./system.sh %*
popd
