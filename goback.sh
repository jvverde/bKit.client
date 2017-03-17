#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"       #Full DIR

exists() { type "$1" >/dev/null 2>&1;}
die() { 
	echo -e "$@" >&2 
	exit 1
}

DATE=$1
rsync -acR --out-format="%p|%t|%o|%i|%b|%l|%f" ".backups/$DATE/./" . || die "Problemas ao actualizar" 

echo "Actualizaçao feita com com sucesso"
