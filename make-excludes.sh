#!/usr/bin/env bash
SDIR=$(dirname -- "$(readlink -en -- "$0")")	#Full SDIR
source "$SDIR/lib/functions/all.sh"

COPY=(excludes-all.txt)
WIN=excludes-windows.txt
UNIX=excludes-unix.txt
BKIT=excludes-bkit.txt
SRCDIR="$SDIR/excludes"
DST="$SDIR/conf/excludes.txt"
[[ -e $DST ]] || mkdir -pv "${DST%/*}"


EXCDIR="${1:-$SRCDIR}"
DSTFILE="${2:-$DST}"

[[ -d $EXCDIR ]] || die "Usage:\n\t$0 [exclude-files-dir]" 

OS=$(uname -o|tr '[:upper:]' '[:lower:]')
{
	for F in "${COPY[@]}"
	do 
		echo -e "\n# From $F\n"
		cat "$EXCDIR/$F"
	done
	
	echo -e "\n# From BKIT\n"
	bash "$SDIR/tools/bkit-exc.sh" "$EXCDIR/$BKIT"
	
	[[ $OS == 'cygwin' ]] && {
		echo -e "\n\n#\tFrom windows-exc\n"
		bash "$SDIR/tools/windows-exc.sh" "$EXCDIR/$WIN"
		echo -e "\n\n#\tFrom registry\n"
		bash "$SDIR/tools/hklm.sh" | bash "$SDIR/tools/windows-exc.sh" || true
	} || {
		echo -e "\n\n#\tFrom unix\n"
		cat "$EXCDIR/$UNIX"
	}
}> "$DSTFILE"
