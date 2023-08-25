@echo off
for /f "skip=1 tokens=1,2,3,4,5" %%a in ('wmic logicaldisk get deviceid^,volumename^,VolumeSerialNumber^,filesystem^,drivetype') do (
    set "deviceid=%%a"
    set "volumename=%%b"
    set "volumeserialnumber=%%c"
    set "filesystem=%%d"
    set "drivetype=%%e"

    if not "!deviceid!" == "" (
        echo !deviceid!^|!volumename!^|!volumeserialnumber!^|!filesystem!^|!drivetype!
    )
)
