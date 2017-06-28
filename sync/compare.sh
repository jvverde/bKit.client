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
        --delete-delay
        --force
        --delete-excluded
)
bash "$SDIR/sync-repos.sh" --reverse "${OPTIONS[@]}" "$@"
