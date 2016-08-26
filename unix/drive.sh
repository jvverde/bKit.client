#!/bin/bash
DEV=$1
NAME=$(lsblk -ln -o LABEL $DEV)
NAME=${NAME:=$(lsblk -ln -o PARTLABEL $DEV)}
NAME=${NAME:=$(lsblk -ln -o VENDOR,MODEL ${DEV%%[0-9]*})}
NAME=${NAME:=_}
NAME=${NAME//[[:space:]]/}
FILESYSTEM=$(lsblk -ln -o FSTYPE $DEV)
DRIVETYPE=$(lsblk -ln -o TRAN ${DEV%%[0-9]*})
VOLUMESERIALNUMBER=$(lsblk -ln -o UUID $DEV)
echo NAME $NAME
echo FILESYSTEM $FILESYSTEM
echo DRIVETYPE $DRIVETYPE
echo VOLUMESERIALNUMBER $VOLUMESERIALNUMBER


