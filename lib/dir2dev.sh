#!/usr/bin/env bash
declare -r sdir="$(dirname -- "$(readlink -ne -- "$0")")"                          #Full dir

source "$sdir/functions/all.sh"

declare dir="$(readlink -ne -- "${1:-.}")"

declare dev=""

if [[ -b $dir ]]
then
	dev="$dir"
else
	declare mountpoint=""
	mountpoint="$(stat -c%m "$dir")" || die "Cannot find mountpoint point of '$dir'"
	#Find the top most mountpoint point. We need this for example for BTRFS subvolumes which are mountpointing points
	mountpoint="$(echo "$mountpoint" |fgrep -of <(df --sync --output=target |tail -n +2|sort -r)|head -n1)"
	[[ ${BKITCYGWIN+x} == x ]] && exists cygpath && dir=$(cygpath "$dir")
	
	dev=$(df --output=source "$mountpoint"|tail -1)
	[[ ${BKITCYGWIN+x} != x && ! -b $dev ]] && exists lsblk && {
		#echo try another way >&2
		dev="$(lsblk -ln -oNAME,MOUNTPOINT |awk -v m="$mountpoint" '$2 == m {printf("/dev/%s",$1)}')"
	}
fi

[[ -z $dev ]] && die "I couldn't find a dev for $dir" 

[[ ${BKITCYGWIN+x} == x && ! $dev =~ ^.: ]] && die "'$dev' isn't valid disc"
[[ ${BKITCYGWIN+x} != x && ! -b $dev ]] && die "'$dev' isn't valid block device"

echo "$dev"

