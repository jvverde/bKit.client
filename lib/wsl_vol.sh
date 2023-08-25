#!/usr/bin/env bash
#https://unix.stackexchange.com/questions/726732/how-can-i-get-the-volume-label-of-a-windows-disk-in-a-wsl-shell
#See also https://stackoverflow.com/questions/1663565/list-all-devices-partitions-and-volumes-in-powershell
mount | grep "^drvfs on .* 9p" | awk '{print $3}' |
	while read mnt
   	do 
        	drv="${mnt:0-1}"
        	echo -en "${mnt}\t"
        	powershell.exe -c "(Get-Volume $drv).FilesystemLabel"
	done
