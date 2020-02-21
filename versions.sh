#!/usr/bin/env bash
sdir="$(dirname -- "$(readlink -ne -- "$0")")"       #Full dir

source "$sdir/ccrsync.sh"

while [[ $1 =~ ^- ]]
do
	key="$1" && shift
	case "$key" in
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
			die Unknown	option $key
		;;
	esac
done

restordir=("$@")

originaldir=( "${restordir[@]}" )

OLDIFS=$IFS
IFS="
"
exists cygpath && restordir=( $(cygpath -u "${originaldir[@]}") ) && originaldir=( $(cygpath -w "${restordir[@]}") )

restordir=( $(readlink -m "${restordir[@]}") )

IFS=$OLDIFS

perm=(--acls --owner --group --super --numeric-ids)
options=(
	--archive
	--no-recursive
	--dirs
	--hard-links
	--human-readable
	--dry-run
)

mktempdir fakeroot

for dir in "${restordir[@]}"
do

	source "$sdir/lib/rvid.sh" "$dir" || die "Can't source rvid"

	root="$(stat -c%m "$dir")" || die "Can't find mounting point for '$dir'"

	dir="${dir#$root}"										#remove mounting point from path => relative path

	versions=( $(rsync --list-only "$BACKUPURL/$BKIT_RVID/.snapshots/@GMT-*"|grep -Po '@GMT-.+$') ) 		#get a list of all snapshots in backup

	for V in "${versions[@]}"
	do
		fmt="--out-format=$V|%o|%i|%M|%l|%f"
		src="$BACKUPURL/$BKIT_RVID/.snapshots/$V/data/$dir"
		rsync "${RSYNCOPTIONS[@]}" "$fmt" "${options[@]}" "$src" "$fakeroot/" 2>/dev/null
	done | sort | {
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
