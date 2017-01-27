#!/bin/bash
exists() { type "$1" >/dev/null 2>&1;}
exists wmic && {
	UUID="$(wmic csproduct get uuid /format:textvaluelist.xsl |awk -F "=" 'tolower($1) ~ /uuid/ {print $2}' | sed 's#\r+##g' | sed -E 's#\s#_#g')"
	DOMAIN="$(wmic computersystem get domain /format:textvaluelist.xsl |awk -F "=" 'tolower($1) ~  /domain/ {print $2}' | sed 's#\r+##g' | sed -E 's#\s#_#g')"
	#get computer name and replace any occurency of a 'white space' by '_', a dot by '-' and suppress any '\r'
	NAME="$(wmic computersystem get name /format:textvaluelist.xsl |awk -F "=" 'tolower($1) ~  /name/ {print $2}' | sed 's#\r+##g' | sed 's#\.#-#g' | sed -E 's#\s#_#g')"
	true
} || {
	UUID="$(dmidecode -s system-uuid 2>/dev/null)"
	true ${UUID:=$(cat /sys/devices/virtual/dmi/id/product_uuid 2>/dev/null)}
	true ${UUID:=$(cat /var/lib/dbus/machine-id 2>/dev/null)}
	true ${UUID:=0000-0000}
	DOMAIN="$(hostname -d)"
	true ${DOMAIN:=local}
	NAME="$(hostname -s)"
	true ${NAME:=noname}
	#echo UUID $UUID
	#echo DOMAIN $DOMAIN
	#echo NAME $NAME
}

