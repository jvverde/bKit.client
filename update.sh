#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"       #Full DIR

exists() { type "$1" >/dev/null 2>&1;}
die() {
	echo -e "$@" >&2
	exit 1
}

OPTIONS=()
while [[ $1 =~ ^- ]]
do
  KEY="$1" && shift
  case "$KEY" in
    --dry-run)
      OPTIONS=('--dry-run')
    ;;
    *)
      echo Unknow option $KEY && usage
    ;;
  esac
done

TARGET="${1:-.}"
exists cygpath && TARGET=$(cygpath -u "$TARGET")
TARGET=$(readlink -nm "$TARGET")

DIR=$(dirname "$TARGET")
[[ -d $DIR ]] || mkdir -pv "$DIR"
REL=${TARGET#$SDIR}
[[ $REL == $SDIR ]] && die "Update dir must be $SDIR or a subdir"
OIFS=$IFS
IFS=/ STEPS=( $REL )
IFS=OIFS

set -f
unset B
FILTERS=()
for S in ${STEPS[@]}
do
  [[ -z $S ]] && continue
  C="$B/$S"
  FILTERS+=( --filter="+ $C" )
  FILTERS+=( --filter="- $B/*" )
  B=$C
done

CONF="$SDIR/conf/conf.init"
[[ -f $CONF ]] || die Cannot found configuration file at $CONF
. "$CONF"                                                                     #get configuration parameters

export RSYNC_PASSWORD="4dm1n"
DST="${2:-.}"
[[ -e $DST ]] || mkdir -p "$DST"
SRC="$UPDATERSRC"
rsync -rlcRb "${FILTERS[@]}" "${OPTIONS[@]}" --backup-dir="${DST%/}/.backups/$(date +"%Y-%m-%dT%H-%M-%S")" --out-format="%p|%t|%o|%i|%b|%l|%f" "$SRC" "${DST%/}/" || die "Problemas ao actualizar $DST"
[[ $? -eq 0 ]] && echo "Actualizaçao feita com com sucesso"
