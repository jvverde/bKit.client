#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"       #Full DIR

exists() { type "$1" >/dev/null 2>&1;}
die() { 
	exists zenity && zenity --error --title "Update" --text "$*"
	echo -e "$@" >&2 
	exit 1
}
ask() {
	exists zenity && {
		zenity --question --title "Pedido de Recuperaçao de Dados" --text "$*" 
		return
	} || echo -e "$@"
}
info() {
	exists zenity && {
		zenity --info --text "$*" 
	} || echo -e "$@"
}

CONF="$SDIR/conf/conf.init"
[[ -f $CONF ]] || die Cannot found configuration file at $CONF
. $CONF                                                                     #get configuration parameters

ask "Vai actualizar o bKit para a versao actual no servidor ($UPDATERURL)\n\nDeseja continuar?" || die 'Asking question'

rsync -rltHbi --exclude-from "$SDIR/excludes/excludes-bkit.txt" "$UPDATERURL/" "$SDIR/" || die "Problemas ao actualizar" ||  exit 1

info "Actualizaçao feita com com sucesso" 
