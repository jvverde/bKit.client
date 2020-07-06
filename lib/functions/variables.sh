#!/usr/bin/env bash
#export variables
set -ue

declare -F _f9d34be91922978de0c207775f6091df > /dev/null 2>&1 \
  && [[ ${1+$1} != -f ]] \
  && return

_f9d34be91922978de0c207775f6091df(){ #We want unique name. This is created with a tool buy hashing this file
  echo Exporting variables >&2
  declare -gx OS="$(uname -o |tr '[:upper:]' '[:lower:]')"

  [[ $OS == cygwin ]] && declare -gx BKITCYGWIN="$(uname -a)"

  if [[ ${BKITCYGWIN+isset} == isset ]] && (id -G|grep -qE '\b544\b')
  then
      #https://support.microsoft.com/en-us/help/243330/well-known-security-identifiers-in-windows-operating-systems
      #https://docs.microsoft.com/en-gb/openspecs/windows_protocols/ms-dtyp/81d92bba-d22b-4a8c-908a-554ab29148ab
      #Get the Administraor user in localized language
      declare admin="$(wmic PATH win32_UserAccount where "sid like 'S-1-5-21%%-500'" get Name|
        tr -d '\r'|
        tail -n +2|
        head -n1|
        sed -E 's/\s+$//'
      )"
      true ${admin:=Administrator} #this is a fallback
      declare -gx BKITISADMIN=YES
      declare -gx BKITUSER="$admin"
  else
    declare -gx BKITUSER="$(id -nu)"
  fi
}

_f9d34be91922978de0c207775f6091df

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  echo BKITUSER=$BKITUSER
  echo OS=$OS
  [[ ${BKITCYGWIN+isset} == isset ]] && echo BKITCYGWIN=$BKITCYGWIN
  [[ ${BKITISADMIN+isset} == isset ]] && echo BKITISADMIN=$BKITISADMIN
fi