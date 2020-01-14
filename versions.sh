#!/usr/bin/env bash
SDIR="$(dirname -- "$(readlink -ne -- "$0")")"       #Full DIR

source "$SDIR/ccrsync.sh"

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
		-a|--all ) 
			all="all"
		;;
		-d|--detail ) 
			detail="detail"
		;;
		*)
			die Unknown	option $KEY
		;;
	esac
done

RESTOREDIR=("$@")

ORIGINALDIR=( "${RESTOREDIR[@]}" )

OLDIFS=$IFS
IFS="
"
exists cygpath && RESTOREDIR=( $(cygpath -u "${ORIGINALDIR[@]}") ) && ORIGINALDIR=( $(cygpath -w "${RESTOREDIR[@]}") )

RESTOREDIR=( $(readlink -m "${RESTOREDIR[@]}") )

IFS=$OLDIFS

PERM=(--acls --owner --group --super --numeric-ids)
OPTIONS=(
	--archive
	--no-recursive
	--dirs
	--hard-links
	--human-readable
	--dry-run
)

mktempdir FAKEROOT

for DIR in "${RESTOREDIR[@]}"
do

	source "$SDIR/lib/rvid.sh" "$DIR" || die "Can't source rvid"

	ROOT="$(stat -c%m "$DIR")" || die "Can't find mounting point for '$DIR'"

	DIR="${DIR#$ROOT}"										#remove mounting point from path => relative path

	VERSIONS=( $(rsync --list-only "$BACKUPURL/$BKIT_RVID/.snapshots/@GMT-*"|grep -Po '@GMT-.+$') ) 		#get a list of all snapshots in backup

	for V in "${VERSIONS[@]}"
	do
		FMT="--out-format=$V|%o|%i|%M|%l|%f"
		SRC="$BACKUPURL/$BKIT_RVID/.snapshots/$V/data/$DIR"
		rsync "${RSYNCOPTIONS[@]}" "$FMT" "${OPTIONS[@]}" "$SRC" "$FAKEROOT/" 2>/dev/null
	done| sort | {
		[[ ${detail+isset} == isset ]] && cat || 
		[[ ${all+isset} == isset ]] && cut -d'|' -f1  || 
		awk -F'|' ' 
			{
				LINES[$2 $3 $4 $5 $6] = $1 " have a last modifed version at " $4 " of " $6 #supress the first field(=snapshot) id all the other are the same. Just show one
			}
			END{
				for (L in LINES) print LINES[L]
			}
		' | sort
	}	
done
