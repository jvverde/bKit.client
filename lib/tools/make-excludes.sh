#!/usr/bin/env bash
sdir=$(dirname -- "$(readlink -en -- "$0")")	#Full sdir
sdir="${sdir%/client*}/client" 

source "$sdir/lib/functions/all.sh"

all=all
WIN=excludes-windows.txt
unix=unix
BKIT=excludes-bkit.txt


srcdir="${1:-"$sdir/excludes"}"
destfile="${2:-"$VARDIR/excludes/excludes.txt"}"

[[ -e $destfile ]] || mkdir -pv "${destfile%/*}"


[[ -d $srcdir ]] || die "Usage:\n\t$0 [exclude-files-dir]" 

{
	echo -e "\n# From ALL\n"
	find "$srcdir/$all" -type f -exec cat "{}" '+'
	
	echo -e "\n# From $BKIT\n"
	bash "$sdir/excludes/bkit-exc.sh" "$srcdir/$BKIT"
	
	[[ $OS == 'cygwin' ]] && {
		echo -e "\n\n#\tFrom windows-exc\n"
		bash "$sdir/tools/windows-exc.sh" "$srcdir/$WIN"
		echo -e "\n\n#\tFrom registry\n"
		bash "$sdir/tools/hklm.sh" | bash "$sdir/tools/windows-exc.sh" || true
	} || {
		echo -e "\n\n#\tFrom unix\n"
		find "$srcdir/$unix" -type f -exec cat "{}" '+'
		cat "$srcdir/$unix"
	}
}> "$destfile"
