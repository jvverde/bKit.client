#!/usr/bin/env bash
declare -p _0f2cb7c5baf31e857ec0d6ff74d11dbd > /dev/null 2>&1 && return
declare -r _0f2cb7c5baf31e857ec0d6ff74d11dbd=1

PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
declare -gx OS="$(uname -o |tr '[:upper:]' '[:lower:]')"

[[ $OS == cygwin ]] && declare -gx BKITCYGWIN="$(uname -a)"

if [[ ${BKITCYGWIN+isset} == isset ]] && (id -G|grep -qE '\b544\b')
then
    #https://support.microsoft.com/en-us/help/243330/well-known-security-identifiers-in-windows-operating-systems
    #https://docs.microsoft.com/en-gb/openspecs/windows_protocols/ms-dtyp/81d92bba-d22b-4a8c-908a-554ab29148ab
    declare admin="$(wmic PATH win32_UserAccount where "sid like 'S-1-5-21%%-500'" get Name|tr -d '\r'|tail -n +2|head -n1|sed -E 's/\s+$//')"
    true ${admin:=Administrator} #this is a fallback
    declare -gx BKITISADMIN=YES
    declare -gx BKITUSER="$admin"
else
  declare -gx BKITUSER="$(id -nu)"
fi
