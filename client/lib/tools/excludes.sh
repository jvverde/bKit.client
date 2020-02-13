#!/usr/bin/env bash
#Make a filter from excludes files in excludir directory
set -u
declare -r sdir="$(dirname "$(readlink -f "$0")")"
declare -r base="${sdir%/lib*}"               #assuming we are inside a lib directory under client area

declare -r excludedir="${1:-"$base/excludes"}"

find "$excludedir/all" -type f -print0 |xargs -r0I{} cat "{}" | grep -vP ^# | perl -lape 's#^#-/ #'
find "$excludedir/bkit" -type f -exec cat "{}" '+' | grep -vP ^# | perl -lape "s#^#-/ $base/#"
#[[ -e $EXCLUDESALL ]] && cat "$EXCLUDESALL" | sed -E 's#.+#-/ &#' >> "$EXCL"
OS=$(uname -o |tr '[:upper:]' '[:lower:]')

[[ $OS == cygwin ]] && {
	bash "$sdir/excludes/hklm.sh"| bash "$sdir/excludes/w2f.sh"
	find "$excludedir/windows" -type f -print0 | xargs -r0I{} cat "{}" | grep -vP ^# | bash "$sdir/excludes/w2f.sh"
}

[[ $OS != cygwin ]] && {
	find "$excludedir/unix" -type f -print0 | xargs -r0I{} cat "{}" | grep -vP ^# | sed -E 's#.+#-/ &#'
}

