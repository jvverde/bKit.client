#!/usr/bin/env bash
set -u
declare -r sdir=$(dirname -- "$(readlink -en -- "$0")")	#Full sdir
declare -r base="${sdir%/lib*}" #assuming we are inside a lib directory under client area

source "$base/lib/functions/all.sh"

all=all
WIN=excludes-windows.txt
unix=unix
bkit=bkit


srcdir="${1:-"$base/excludes"}"

[[ -d $srcdir ]] || die "Usage:\n\t$0 [exclude-files-dir]" 

destfile="${2:-"$VARDIR/excludes/excludes.lst"}"

[[ -e $destfile ]] || mkdir -pv "${destfile%/*}"

{
	echo -e "\n# From ALL\n"
	find "$srcdir/$all" -type f -exec cat "{}" '+'
	
	echo -e "\n# From $bkit\n"
	find "$srcdir/$bkit" -type f -exec cat "{}" '+' | perl -lape "s#^#$base/#"
	
	[[ $OS == 'cygwin' ]] && {
		echo -e "\n\n#\tFrom windows-exc\n"
		bash "$sdir/excludes/windows-exc.sh" "$srcdir/$WIN"
		echo -e "\n\n#\tFrom registry\n"
		bash "$sdir/excludes/hklm.sh" | bash "$sdir/excludes/windows-exc.sh" || true
	} || {
		echo -e "\n\n#\tFrom unix\n"
		find "$srcdir/$unix" -type f -exec cat "{}" '+'
	}
} > "$destfile"
