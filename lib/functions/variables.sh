#!/usr/bin/env bash
#export variables
declare -F _bkit_export_variables > /dev/null 2>&1 && [[ ! ${1+$1} =~ ^-f ]] && return

_bkit_export_variables(){
  declare -gx OS="$(uname -o |tr '[:upper:]' '[:lower:]')"
  
  [[ $OS == cygwin ]] && declare -gx BKITCYGWIN="$(uname -a)"

  if [[ ${BKITCYGWIN+isset} == isset ]] && (id -G|grep -qE '\b544\b')
  then
      #https://support.microsoft.com/en-us/help/243330/well-known-security-identifiers-in-windows-operating-systems
      #https://docs.microsoft.com/en-gb/openspecs/windows_protocols/ms-dtyp/81d92bba-d22b-4a8c-908a-554ab29148ab
      #Get the Administraor user in localized language
      declare admin="$(wmic PATH win32_UserAccount where "sid like 'S-1-5-21%%-500'" get Name|
        tr -d '\r'|         #remove CR
        tail -n +2|         #ignore the header line
        head -n1|           #get only first line
        sed -E 's/\s+$//'   #clean traling spaces 
      )"
      true "${admin:=Administrator}" #this is a fallback
      declare -gx BKITISADMIN=YES
      declare -gx BKITUSER="$admin"
  else
    declare -gx BKITUSER="$(id -nu)"
  fi
}

${__SOURCED__:+return} #Intended for shellspec tests

_bkit_export_variables

if [[ ${BASH_SOURCE[0]} == "$0" ]]
then
  echo BKITUSER="$BKITUSER"
  echo OS="$OS"
  [[ ${BKITCYGWIN+isset} == isset ]] && echo BKITCYGWIN="$BKITCYGWIN"
  [[ ${BKITISADMIN+isset} == isset ]] && echo BKITISADMIN="$BKITISADMIN" 
fi