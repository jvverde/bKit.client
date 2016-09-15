#!/bin/bash
die() { echo -e "$@">&2; exit 1; }
[[ -d $1 ]] || die "Usage:\n\t$0 excludefilesdir" 
EXCDIR=$(readlink -f "$1")
SDIR="$(dirname "$(readlink -f "$0")")"

COPY=(excludes-all.txt excludes-bkit.txt)
WIN=excludes-windows.txt	
OS=$(uname -o|tr '[:upper:]' '[:lower:]')
for F in "${COPY[@]}"
do 
	echo -e "\n# From $F\n"
	cat "$EXCDIR/$F"
done
[[ $OS == 'cygwin' ]] && {
	echo -e "\n# From windows-exc\n"
	bash "$SDIR/windows-exc.sh" "$EXCDIR/$WIN"
	echo -e "\n# From registry\n"
	bash "$SDIR/hklm.sh"
}
