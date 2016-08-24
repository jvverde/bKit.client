#VOLUMEINFO="$(fsutil fsinfo volumeinfo $DRIVE:\\ | tr -d '\r')" 
#VOLUMENAME=$(echo -e "$VOLUMEINFO"| awk -F ":" 'toupper($1) ~ /VOLUME NAME/ {print $2}' | 
#	sed -e 's/^ *//' -e 's/ *$//'  -e 's/[^a-z0-9]/-/gi' -e 's/^$/_/' | sed -E 's/\s/_/g'
#)
#VOLUMESERIALNUMBER=$(echo -e "$VOLUMEINFO"| awk -F ":" 'toupper($1) ~ /VOLUME SERIAL NUMBER/ {print toupper($2)}' | 
#	sed -e 's/^ *//' -e 's/ *$//' -e 's/^0x//gi' -e 's/^$/_/' | sed -E 's/\s/_/g'
#)
#FILESYSTEM=$(echo -e "$VOLUMEINFO"| awk -F ":" 'toupper($1) ~ /FILE SYSTEM NAME/ {print $2}' | 
#	sed -e 's/^ *//' -e 's/ *$//' -e 's/^0x//gi' -e 's/^$/_/' | sed -E 's/\s/_/g'
#)
#DRIVETYPE=$(fsutil fsinfo driveType $DRIVE: | tr -d '\r'| 
#	sed -e "s/^$DRIVE:.*- *//" -e 's/[^a-z0-9]/-/gi' -e 's/^$/_/' | sed -E 's/\s/_/g'
#)
DEV=$1
#NAME=$(lsblk -ln -o NAME,SIZE,LABEL,TRAN,PARTLABEL,UUID,PARTUUID,FSTYPE,MOUNTPOINT,TYPE,PARTTYPE,SERIAL,VENDOR,MODEL $DEV)
NAME=$(lsblk -ln -o LABEL $DEV)
NAME=${NAME:=$(lsblk -ln -o PARTLABEL $DEV)}
NAME=${NAME// /_}
FILESYSTEM=$(lsblk -ln -o FSTYPE $DEV)
DRIVETYPE=$(lsblk -ln -o TRAN ${DEV%%[0-9]*})
VOLUMESERIALNUMBER=$(lsblk -ln -o UUID $DEV)
echo NAME $NAME
echo FILESYSTEM $FILESYSTEM
echo DRIVETYPE $DRIVETYPE
echo VOLUMESERIALNUMBER $VOLUMESERIALNUMBER


