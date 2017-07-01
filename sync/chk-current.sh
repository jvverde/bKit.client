#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH

SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR

OPTIONS=(
	--dry-run 
	--relative
	--recursive
	--times
	--links
	--itemize-changes
	--prune-empty-dirs
)
bash "$SDIR/sync-repos.sh" --snap="@current" "${OPTIONS[@]}" "$@"
