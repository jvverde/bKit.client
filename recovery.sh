#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"       #Full DIR

exists() { type "$1" >/dev/null 2>&1;}
die() {
	echo -e "$@" >&2
	exit 1
}
ask() {
	[[ $YES ]] && return
	echo -e "$@"
}
info() {
	echo -e "$@"
}

function get_json(){
	grep -Po '(?<="'$1'":")(?:|.*?[^\\])(?=")'
}

while [[ $1 =~ ^- ]]
do
	KEY="$1" && shift
	case "$KEY" in
		-l|-log|--log)
			exec 1>"$1"
			shift
		;;
		-f|--force)
			FORCE=true
		;;
		-y|--yes)
			YES=true
		;;
		*)
			die Unknow option $KEY
		;;
	esac
done

[[ -e $1 ]] || die "Usage:\n\t${0//\\/\\\\} resource"

DST=$2

#DST must be null or must exists
[[ -z $DST || -e $DST ]] || die "$DST doesn't exists"

exists cygpath && RESOURCE=$(cygpath "$1") && SDIR=$(cygpath "$SDIR") || RESOURCE=$1

BACKUP=$(get_json backup < "$RESOURCE")
DISK=$(get_json drive < "$RESOURCE")
COMPUTER=$(get_json computer < "$RESOURCE")
DIR=$(get_json path < "$RESOURCE" )
ENTRY=$(get_json entry < "$RESOURCE")

IFS='.' read -r DRIVE VOLUME NAME DESCRIPTION FS <<< "$DISK"

[[ -z $DST ]] && {
	DEV=$(bash "$SDIR/findDrive.sh" $VOLUME) || die Cannot find the volume $VOLUME on this computer
	[[ -b $DEV ]] && {
	  die "First, you need to mount '$DEV'"
	} || BASE=$DEV
}

BACKUPDATE=$(echo $BACKUP|sed -E 's/.+([0-9]{4}).([0-9]{2}).([0-9]{2})-([0-9]{2}).([0-9]{2}).([0-9]{2})/\1-\2-\3T\4:\5:\6 GMT/g'| xargs -I{} date -d "{}" )
FOLDER=$(readlink -mn "$BASE/$DIR/$ENTRY")
ask "A pasta '$FOLDER' vai ser recuperada a partir do backup efectuado em:\n\t$BACKUPDATE\n\nDeseja continuar?" || exit 1

[[ -n $DST ]] || DST=$BASE

exists cygpath && DST=$(cygpath "$DST")

. "$SDIR/computer.sh"                                                               #get $DOMAIN, $NAME and $UUID
THIS=$DOMAIN.$NAME.$UUID

[[ $THIS != $COMPUTER ]] && [[ -z $FORCE ]] && die This is not the same computer;
CONF=$SDIR/conf/conf.init
[[ -f $CONF ]] || die Cannot found configuration file at $CONF
. "$CONF"                                                                     #get configuration parameters

#Change backupurl for cases where we want to force a backup/migrate for from different computer
BACKUPURL="${BACKUPURL%/*}/$COMPUTER"

SRC=$(echo $BACKUPURL/$DISK/.snapshots/$BACKUP/data/./$DIR/$ENTRY|sed s#/\\./\\./#/./#g)       #for cases where DIR=.

FMT='--out-format="%p|%t|%o|%i|%b|%l|%f"'
#PASS="--password-file=$SDIR/conf/pass.txt"
PERM="--acls --owner --group --super --numeric-ids"
OPTIONS="--delete-delay --delay-updates --force --stats --fuzzy"
export RSYNC_PASSWORD="$(cat "$SDIR/conf/pass.txt")"
rsync -rlitzvvhRP $PERM $OPTIONS $FMT "$SRC" "$DST/" || die "Problemas ao recuperar a pasta '$FOLDER'"

OSTYPE=$(uname -o |tr '[:upper:]' '[:lower:]')
[[ $OSTYPE == 'cygwin' && $DISK =~  NTFS && -n ${BASE+x} ]] && {
	info "A descarregar as ACLs"
	
	SRCMETA="$BACKUPURL/$DISK/.snapshots/$BACKUP/metadata/./.tar/"
	METADATADIR=$(cygpath "$SDIR/cache/metadata/by-volume/${VOLUME}/")
	[[ -d $METADATADIR ]] || mkdir -pv $METADATADIR
	rsync -rtizR $PERM $FMT "$SRCMETA" "$METADATADIR" || die "Problema ao descarregar as ACLs"
	RUN=$SDIR/run/metadata.$$
	mkdir -p "$RUN"
	TARDIR=.bkit/$DIR
	[[ -d $FOLDER ]] && TARDIR=$TARDIR/$ENTRY
	TARDIR=${TARDIR//\/.\//\/}					#repacle any sequence of "/./" by "/"
	info "A desempacotar as ACLs"
	tar --extract --verbose --directory "$RUN" --file "$METADATADIR/.tar/dir.tar" "$TARDIR" || die "Problema ao desempacotar as ACLs"
	DRIVE=$(cygpath -w "$DST")
	SUBINACL=$(find "$SDIR/3rd-party" -type f -name "subinacl.exe" -print -quit)
	[[ -f $SUBINACL ]] || die "A aplicação 'subinacl.exe' não foi encontrada"
	while read FILE
	do
		info "A aplicar as ACLs presentes em $FILE"
		iconv -f UTF-16LE -t UTF-8 "$FILE" |
			sed -E 's#^\+File [A-Z]:#+File '${DRIVE:0:1}':#i' |
			iconv  -f UTF-8 -t UTF-16LE > "$FILE.acl"
		"$SUBINACL" /playfile "$(cygpath -w "$FILE.acl")" || die 'Erro ao aplicar as ACLs'
	done < <(find "$RUN/$TARDIR" -type f \( -name '.bkit.acls.f' -o -name '.bkit.this.acls.f' \) -print)
	rm -rf "$RUN"
}

info "A pasta '$FOLDER' foi recuperada com sucesso"
