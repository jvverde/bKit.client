#!/usr/bin/env bash
declare -p _0f2cb7c5baf31e857ec0d6ff74d11dbd > /dev/null 2>&1 && return
declare -r _0f2cb7c5baf31e857ec0d6ff74d11dbd=1

PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
declare -gx OS="$(uname -o |tr '[:upper:]' '[:lower:]')"

if (id -G|grep -qE '\b544\b') && [[ $OS == cygwin ]]
then
    declare -gx BKITUSER="Administrator"
else
  declare -gx BKITUSER="$(id -nu)"
fi
