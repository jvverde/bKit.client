#!/usr/bin/env bash
_findxisting(){
	declare dir="$1"
	[[ -e $dir ]] && echo "$dir" && return
	declare parent="$(dirname -- "$dir")"
	[[ "$parent" == "$dir" ]] && echo $dir && return
	echo "$(_findxisting "$parent")"
}

_dir2dev(){
	declare -r sdir="$(dirname -- "$(readlink -ne -- "${BASH_SOURCE[0]}")")"                          #Full dir

	declare dir="$(readlink -nm -- "${1:-.}")"

	declare dev=""

	source "$sdir/functions/all.sh"

	if [[ -b $dir ]]
	then
		dev="$dir"
	else
		declare mountpoint=""
		[[ -e $dir ]] || dir="$(_findxisting "$dir")"
		mountpoint="$(stat -c%m "$dir")" || die "Cannot find mountpoint point of '$dir'"
		#Find the top most mountpoint point. We need this for example for BTRFS subvolumes which are mountpointing points
		mountpoint="$(echo "$mountpoint" |fgrep -of <(df --sync --output=target 2>/dev/null|tail -n +2|sort -r)|head -n1)"
		[[ ${BKITCYGWIN+x} == x ]] && exists cygpath && dir=$(cygpath "$dir")
		
		dev=$(df --output=source "$mountpoint"|tail -1)
		[[ ${BKITCYGWIN+x} != x && ! -b $dev ]] && exists lsblk && {
			#echo try another way >&2
			dev="$(lsblk -ln -oNAME,MOUNTPOINT |awk -v m="$mountpoint" '$2 == m {printf("/dev/%s",$1)}')"
		}
	fi

	[[ -z $dev ]] && die "I couldn't find a dev for $dir" 

	[[ ${BKITCYGWIN+x} == x && ! $dev =~ ^.: ]] && die "'$dev' isn't valid windows disk"
	[[ ${BKITCYGWIN+x} != x && ! -b $dev ]] && die "'$dev' isn't valid block device"

	echo "$dev"
}

_exportdev(){
	declare -gx BKITDEV="$(_dir2dev "${1:-.}")"
}

${__SOURCED__:+return} #Intended for shellspec tests

if [[ ${BASH_SOURCE[0]} == "$0" ]] #if not sourced
then
	_dir2dev "${1:-.}"
else
	_exportdev "${1:-.}"
fi