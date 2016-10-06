#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"       #Full DIR

exists() { type "$1" >/dev/null 2>&1;}
die() { 
	exists zenity && zenity --error --title "Backup Recovery" --text "$*"
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

function get_json(){
	grep -Po '(?<="'$1'":")(?:|.*?[^\\])(?=")'
}

[[ -e $1 ]] || die "Usage:\n\t${0//\\/\\\\} resource"

exists cygpath && RESOURCE=$(cygpath "$1") && SDIR=$(cygpath "$SDIR") || RESOURCE=$1

BACKUP=$(get_json backup < "$RESOURCE")
DISK=$(get_json drive < "$RESOURCE")
COMPUTER=$(get_json computer < "$RESOURCE")
DIR=$(get_json path < "$RESOURCE" )
ENTRY=$(get_json entry < "$RESOURCE")

IFS='.' read -r DRIVE VOLUME NAME DESCRIPTION FS <<< "$DISK"

DEV=$(bash "$SDIR/findDrive.sh" $VOLUME) || die Cannot find the volume $VOLUME on this computer
[[ -b $DEV ]] && {
  die "First, you need to mount '$DEV'"
} || DST=$DEV

BACKUPDATE=$(echo $BACKUP|sed -E 's/.+([0-9]{4}).([0-9]{2}).([0-9]{2})-([0-9]{2}).([0-9]{2}).([0-9]{2})/\1-\2-\3T\4:\5:\6 GMT/g'| xargs -I{} date -d "{}" )
FOLDER="$DST/$DIR/$ENTRY"
ask "A pasta '$FOLDER' vai ser recuperada a partir do backup efectuado em:\n\t$BACKUPDATE\n\nDeseja continuar?" || exit 1

exists cygpath && DST=$(cygpath "$DST")

. "$SDIR/computer.sh"                                                               #get $DOMAIN, $NAME and $UUID
THIS=$DOMAIN.$NAME.$UUID

[[ $THIS != $COMPUTER ]] && [[ -n $FORCE ]] && die This is not the same computer; 

CONF="$SDIR/conf/conf.init"
[[ -f $CONF ]] || die Cannot found configuration file at $CONF
. $CONF                                                                     #get configuration parameters

SRC=$(echo $BACKUPURL/$DISK/.snapshots/$BACKUP/data/./$DIR/$ENTRY|sed s#/././#/./#)       #for cases where DIR=.

FMT='--out-format="%p|%t|%o|%i|%b|%l|%f"'
#PASS="--password-file=$SDIR/conf/pass.txt"
PERM="--acls --owner --group --super --numeric-ids"
OPTIONS="--delete-delay --delay-updates --force --stats --fuzzy"
export RSYNC_PASSWORD="$(cat "$SDIR/conf/pass.txt")"
rsync -rlitzvvhRP $PERM $OPTIONS $FMT "$SRC" "$DST/" || die "Problemas ao recuperar a pasta '$FOLDER'"

OSTYPE=$(uname -o |tr '[:upper:]' '[:lower:]')
[[ $OSTYPE == 'cygwin' && $DISK =~  NTFS ]] && (
	SRCMETA="$BACKUPURL/$DISK/.snapshots/$BACKUP/metadata/./.tar/"   
	METADATADIR=$(cygpath "$SDIR/cache/metadata/by-volume/${VOLUME}/")
	rsync -tizR $PERM $FMT "$SRCMETA" "$METADATADIR" || die "Problema ao recuperar as ACLs"
	RUN=$SDIR/run/metadata.$$
	mkdir -pv "$RUN"
	tar --extract --verbose --directory "$RUN" --file "$METADATADIR/.tar/dir.tar" ".bkit/$DIR/"
	DRIVE=$(cygpath -w "$DST")
	DRIVE=${DRIVE:0:1} 
	find "$RUN/.bkit/$DIR" -type f -name '.bkit.acls.f' -print0 |
		LC_ALL='UTF-16' xargs -0rI{} sed -E 's#\+File [A-Z]:#+File '$DRIVE':#i'  {} 
)

info "A pasta '$FOLDER' foi recuperada com sucesso" 
