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
CONF="$SDIR/conf/conf.init"
[[ -f $CONF ]] || die Cannot found configuration file at $CONF
. "$CONF"                                                                     #get configuration parameters

export RSYNC_PASSWORD="4dm1n"
rsync -rlcRb "${OPTIONS[@]}" --backup-dir=".backups/$(date +"%Y-%m-%dT%H-%M-%S")" --out-format="%p|%t|%o|%i|%b|%l|%f" "$UPDATERSRC$1" . || die "Problemas ao actualizar"
[[ $? -eq 0 ]] && echo "Actualizaçao feita com com sucesso"
