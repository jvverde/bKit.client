VOLUMEINFO="$(fsutil fsinfo volumeinfo $DRIVE:\\ | tr -d '\r')" 
VOLUMENAME=$(echo -e "$VOLUMEINFO"| awk -F ":" 'toupper($1) ~ /VOLUME NAME/ {print $2}' | 
	sed -e 's/^ *//' -e 's/ *$//'  -e 's/[^a-z0-9]/-/gi' -e 's/^$/_/' | sed -E 's/\s/_/g'
)
VOLUMESERIALNUMBER=$(echo -e "$VOLUMEINFO"| awk -F ":" 'toupper($1) ~ /VOLUME SERIAL NUMBER/ {print toupper($2)}' | 
	sed -e 's/^ *//' -e 's/ *$//' -e 's/^0x//gi' -e 's/^$/_/' | sed -E 's/\s/_/g'
)
FILESYSTEM=$(echo -e "$VOLUMEINFO"| awk -F ":" 'toupper($1) ~ /FILE SYSTEM NAME/ {print $2}' | 
	sed -e 's/^ *//' -e 's/ *$//' -e 's/^0x//gi' -e 's/^$/_/' | sed -E 's/\s/_/g'
)
DRIVETYPE=$(fsutil fsinfo driveType $DRIVE: | tr -d '\r'| 
	sed -e "s/^$DRIVE:.*- *//" -e 's/[^a-z0-9]/-/gi' -e 's/^$/_/' | sed -E 's/\s/_/g'
)
