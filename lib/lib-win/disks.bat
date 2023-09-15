@echo off
setlocal enabledelayedexpansion

:: Set the paths for PowerShell script and WMIC script
set "powershell_script_path=%~dp0ps_disk_info.ps1"
set "wmic_script_path=%~dp0wmic_disk_info.bat"

:: Pass any arguments to the sub-scripts
set "script_args=%*"

:: Check if PowerShell is available
where powershell > nul 2>&1
set "powershell_available=%errorlevel%"

:: Run appropriate script based on existence and availability
if !powershell_available! equ 0 (
    if exist "%powershell_script_path%" (
        echo Running PowerShell script...
        for /f %%a in ('powershell -ExecutionPolicy Bypass -File "%powershell_script_path%" %script_args%') do (
            set "output=%%a"
            echo !output!
        )
    ) else (
        call "%wmic_script_path%" %script_args%
    )
) else (
    call "%wmic_script_path%" %script_args%
)

endlocal
