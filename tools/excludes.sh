#!/bin/bash
#Make a filter from excludes files in excludir directory
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
OS=$(uname -o |tr '[:upper:]' '[:lower:]')
SDIR="$(dirname "$(readlink -f "$0")")"

EXCLUDESDIR="$1"

find "$EXCLUDESDIR/all" -type f -print0 |xargs -r0I{} cat "{}" | sed -E 's#.+#-/ &#'
#[[ -e $EXCLUDESALL ]] && cat "$EXCLUDESALL" | sed -E 's#.+#-/ &#' >> "$EXCL"
[[ $OS == cygwin ]] && {
	bash "$SDIR/hklm.sh"| bash "$SDIR/w2f.sh"
	find "$EXCLUDESDIR/windows" -type f -print0 | xargs -r0I{} cat "{}" | bash "$SDIR/w2f.sh"
}

[[ $OS != cygwin ]] && {
	find "$EXCLUDESDIR/unix" -type f -print0 | xargs -r0I{} cat "{}" | sed -E 's#.+#-/ &#'
}

