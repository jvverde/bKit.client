@ECHO OFF
SET cdir=%~dp0
SET getCygwin64=%cdir%getCygwin64.ps1
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%getCygwin64%'";