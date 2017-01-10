@ECHO OFF
DIR /B /S %1
REM FOR /F %%B IN ('DIR /B /S *.exe') DO (
  rem findstr /I /N /C:"%1%" %%B
REM )