@echo off
setlocal enabledelayedexpansion

:: Pass drive letter argument to the WMIC script
set "drive_letter=%~1"

:: Construct the WMIC command with the drive letter condition if provided
set "wmic_command=wmic logicaldisk"
if not "%drive_letter%" == "" (
    set "wmic_command=!wmic_command! where DeviceID='%drive_letter%:'"
)

:: Retrieve disk information using the constructed WMIC command
for /f "skip=1 tokens=1,2,3,4,5" %%a in ('wmic logicaldisk get deviceid^,volumename^,VolumeSerialNumber^,filesystem^,drivetype') do (
    set "deviceid=%%a"
    set "drivetype=%%b"
    set "filesystem=%%c"
    set "volumename=%%d"
    set "volumeserialnumber=%%e"

    if not "!deviceid!" == "" (
        echo !deviceid!^|!volumename!^|!volumeserialnumber!^|!filesystem!^|!drivetype!
    )
)

endlocal
