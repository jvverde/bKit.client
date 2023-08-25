$disks = Get-WmiObject Win32_LogicalDisk

foreach ($disk in $disks) {
    $deviceid = $disk.DeviceID
    $volumename = $disk.VolumeName
    $volumeserialnumber = $disk.VolumeSerialNumber
    $filesystem = $disk.FileSystem
    $drivetype = $disk.DriveType

    if ($deviceid -ne $null) {
        "$deviceid|$volumename|$volumeserialnumber|$filesystem|$drivetype"
    }
}
