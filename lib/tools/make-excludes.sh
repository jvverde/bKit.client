#!/usr/bin/env bash
sdir=$(dirname -- "$(readlink -en -- "$0")")	#Full sdir
sdir="${sdir%/client/*}/client" 

source "$sdir/lib/functions/all.sh"

COPY=(excludes-all.txt)
WIN=excludes-windows.txt
UNIX=excludes-unix.txt
BKIT=excludes-bkit.txt
SRCDIR="$sdir/excludes"
DST="$sdir/conf/excludes.txt"
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
	bash "$sdir/tools/bkit-exc.sh" "$EXCDIR/$BKIT"
	
	[[ $OS == 'cygwin' ]] && {
		echo -e "\n\n#\tFrom windows-exc\n"
		bash "$sdir/tools/windows-exc.sh" "$EXCDIR/$WIN"
		echo -e "\n\n#\tFrom registry\n"
		bash "$sdir/tools/hklm.sh" | bash "$sdir/tools/windows-exc.sh" || true
	} || {
		echo -e "\n\n#\tFrom unix\n"
		cat "$EXCDIR/$UNIX"
	}
}> "$DSTFILE"
