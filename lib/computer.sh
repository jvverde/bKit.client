#!/usr/bin/env bash
SDIR=$(dirname -- "$(readlink -ne -- "$0")")	#Full SDIR
source "$SDIR/functions/all.sh"

exists wmic && {
	UUID="$(wmic csproduct get uuid /format:textvaluelist.xsl |tr -d '\r'|sed -E '/^$/d;s/^\s+|\s+$//;s/\s+/_/g'| awk -F "=" 'tolower($1) ~ /uuid/ {print $2}')"
	DOMAIN="$(wmic computersystem get domain /format:textvaluelist.xsl |tr -d '\r'|sed -E '/^$/d;s/^\s+|\s+$//;s/\s+/_/g' | awk -F "=" 'tolower($1) ~  /domain/ {print $2}')"
	NAME="$(wmic computersystem get name /format:textvaluelist.xsl |tr -d '\r'|sed -E '/^$/d;s/^\s+|\s+$//;s/\s+/_/g' | awk -F "=" 'tolower($1) ~  /name/ {print $2}')"
	echo "${DOMAIN:-_}|${NAME:-_}|${UUID:-_}"
} || {
	UUID="$(cat /var/lib/dbus/machine-id 2>/dev/null)"
	true ${UUID:="$(cat /sys/devices/virtual/dmi/id/product_uuid 2>/dev/null)"}
	true ${UUID:="$(cat /sys/class/dmi/id/product_uuid 2>/dev/null)"}
	true ${UUID:="$(cat /sys/class/dmi/id/board_id 2>/dev/null)"}
	true ${UUID:="$(cat /etc/machine-id 2>/dev/null)"}
	true ${UUID:="$(dmidecode -s system-uuid 2>/dev/null)"}
	true ${UUID:="0000-0000"}
	DOMAIN="$(hostname -d)"
	true ${DOMAIN:=local}
	NAME="$(hostname -s)"
	true ${NAME:=noname}
	echo "${DOMAIN:-_}|${NAME:-_}|${UUID:-_}"
}

