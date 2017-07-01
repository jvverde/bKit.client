#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH

SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR

OPTIONS=(
	--dry-run 
	--relative
	--itemize-changes
	--ignore-non-existing
	--ignore-existing
)
SNAP=$(echo "${@: -1}"|sed -E 's#.*/[.]snapshots/(@[^/]+).*#\1#')
bash "$SDIR/sync-repos.sh" --snap="@snap/$SNAP" "${OPTIONS[@]}" "$@"
