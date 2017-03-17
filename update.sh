#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"       #Full DIR

exists() { type "$1" >/dev/null 2>&1;}
die() { 
	echo -e "$@" >&2 
	exit 1
}

CONF="$SDIR/conf/conf.init"
[[ -f $CONF ]] || die Cannot found configuration file at $CONF
. "$CONF"                                                                     #get configuration parameters

#ask "Vai actualizar o bKit para a versao actual no servidor ($UPDATERURL)\n\nDeseja continuar?" || die 'Asking question'
export RSYNC_PASSWORD="4dm1n"
rsync -aRb --backup-dir=".backups/$(date +"%c")" --out-format="%p|%t|%o|%i|%b|%l|%f" "$UPDATERSRC" . || die "Problemas ao actualizar" 

echo "Actualizaçao feita com com sucesso"
