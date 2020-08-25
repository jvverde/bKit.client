#!/usr/bin/env bash
#Make a filter from excludes files in excludir directory
set -u
make_excludes(){
  declare -r sdir="$(dirname "$(readlink -f "$0")")"
  declare -r base="${sdir%/lib*}"               #assuming we are inside a lib directory under client area

  declare -r excludedir="${1:-"$base/excludes"}"

  echo "#From all"
  find "$excludedir/all" -type f -print0 |xargs -r0I{} cat "{}" | grep -vP ^# | perl -lape 's#^#-/ #'
  echo "#From bkit"
  find "$excludedir/bkit" -type f -exec cat "{}" '+' | grep -vP ^# | perl -lape "s#^#- #"
  #[[ -e $EXCLUDESALL ]] && cat "$EXCLUDESALL" | sed -E 's#.+#-/ &#' >> "$EXCL"
  OS=$(uname -o |tr '[:upper:]' '[:lower:]')

  [[ $OS == cygwin ]] && {
    echo "#From HKLM"
  	bash "$sdir/excludes/hklm.sh"| bash "$sdir/excludes/w2f.sh"
    echo "#From windows"
  	find "$excludedir/windows" -type f -print0 | xargs -r0I{} cat "{}" | grep -vP ^# | bash "$sdir/excludes/w2f.sh"
  }

  [[ $OS != cygwin ]] && {
    echo "#From Linux"
  	find "$excludedir/unix" -type f -print0 | xargs -r0I{} cat "{}" | grep -vP ^# | sed -E 's#.+#-/ &#'
    echo "#From FS"
    find "$excludedir/FS" -type f |xargs -rI{} grep -Ff "{}" <(df -a --output=fstype,target)|awk '{print $2}'| perl -lape 's#^#-/ #; s#$#/***#'
  }
}

${__SOURCED__:+return} #Intended for shellspec tests

make_excludes | perl -lape 's#\s+$##'