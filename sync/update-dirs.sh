#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH

SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR

OPTIONS=(
	--relative
	--recursive
	--times
	--links
	--itemize-changes
	--ignore-non-existing
	--ignore-existing
)
bash "$SDIR/sync-repos.sh" --snap="@current" "${OPTIONS[@]}" "$@"
