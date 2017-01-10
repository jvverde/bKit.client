#!/bin/bash
UUID="$(dmidecode -s system-uuid 2>/dev/null)"
true ${UUID:=$(cat /sys/devices/virtual/dmi/id/product_uuid 2>/dev/null)}
true ${UUID:=$(cat /var/lib/dbus/machine-id 2>/dev/null)}
true ${UUID:=0000-0000}
DOMAIN="$(hostname -d)"
true ${DOMAIN:=local}
NAME="$(hostname -s)"
true ${NAME:=noname}
echo UUID $UUID
echo DOMAIN $DOMAIN
echo NAME $NAME
