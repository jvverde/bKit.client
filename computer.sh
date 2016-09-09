#!/bin/bash
UUID="$(wmic csproduct get uuid /format:textvaluelist.xsl |awk -F "=" 'tolower($1) ~ /uuid/ {print $2}' | sed 's#\r+##g' | sed -E 's#\s#_#g')"
DOMAIN="$(wmic computersystem get domain /format:textvaluelist.xsl |awk -F "=" 'tolower($1) ~  /domain/ {print $2}' | sed 's#\r+##g' | sed -E 's#\s#_#g')"
NAME="$(wmic computersystem get name /format:textvaluelist.xsl |awk -F "=" 'tolower($1) ~  /name/ {print $2}' | sed 's#\r+##g' | sed -E 's#\s#_#g')"
