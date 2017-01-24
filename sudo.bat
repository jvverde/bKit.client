@echo OFF
pushd "%~dp0"
call elevate.bat bash.bat %*
popd
