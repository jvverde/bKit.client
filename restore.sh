#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"       #Full DIR

exists() { type "$1" >/dev/null 2>&1;}
die() {
	echo -e "$@" >&2
	exit 1
}

RSYNCOPTIONS=()

while [[ $1 =~ ^- ]]
do
	KEY="$1" && shift
	case "$KEY" in
		-- )
			while [[ $1 =~ ^- ]]
			do
				RSYNCOPTIONS+=("$1")
				shift
			done
		;;
		*)
			die Unknown	option $KEY
		;;
	esac
done

BASEDIR=("$@")

ORIGINALDIR=( "${BASEDIR[@]}" )

OLDIFS=$IFS
IFS="
"
exists cygpath && BASEDIR=( $(cygpath -u "${ORIGINALDIR[@]}") ) && ORIGINALDIR=( $(cygpath -w "${BASEDIR[@]}") )

BASEDIR=( $(readlink -m "${BASEDIR[@]}") )

ROOTS=( $(stat -c%m "${BASEDIR[@]}") )
ROOT=${ROOTS[0]}

[[ -e "$ROOT" ]] || die "I didn't find a disk for directory/file: '${BASEDIR[0]}'"


STARTDIR=()
for I in ${!ROOTS[@]}
do
	[[ "${ROOTS[$I]}" == "$ROOT" ]] || {
		warn "Roots are not in the same logical volume. These will be ignored:\n\t${ORIGINALDIR[$I]}" && continue
	}
	DIR=${BASEDIR[$I]#$ROOT}
	DIR=${DIR#/}
	STARTDIR+=( "$DIR" )
done

IFS='|' read -r VOLUMENAME VOLUMESERIALNUMBER FILESYSTEM DRIVETYPE <<<$("$SDIR/drive.sh" "$ROOT" 2>/dev/null)
IFS=$OLDIFS

exists cygpath && DRIVE=$(cygpath -w "$ROOT")
DRIVE=${DRIVE%%:*}

#compute Remote Volume ID
RVID="${DRIVE:-_}.${VOLUMESERIALNUMBER:-_}.${VOLUMENAME:-_}.${DRIVETYPE:-_}.${FILESYSTEM:-_}"

CONF=$SDIR/conf/conf.init
[[ -f $CONF ]] || die Cannot found configuration file at $CONF
. "$CONF"                                                                     #get configuration parameters

SRCS=()
for SRC in ${STARTDIR[@]}
do
	SRCS+=( "$BACKUPURL/$RVID/@current/data/./$STARTDIR" )
done

FMT='--out-format="%p|%t|%o|%i|%b|%l|%f"'
PERM=(--acls --owner --group --super --numeric-ids)
OPTIONS=(
	--dry-run
	--backup
	--backup-dir=".bkit-backups/$(date +"%c")"
	--archive
	--hard-links
	--compress
	--human-readable
	--relative
	--partial
	--partial-dir=.rsync-partial
	--delay-updates
	--delete-delay   
)
export RSYNC_PASSWORD="$(cat "$SDIR/conf/pass.txt")"
rsync -vv "${RSYNCOPTIONS[@]}" "${PERM[@]}" "$FMT" "${OPTIONS[@]}" "${SRCS[@]}" "$ROOT" || die "Problemas ao recuperar: $!"

echo "A pasta foi recuperada com sucesso"
