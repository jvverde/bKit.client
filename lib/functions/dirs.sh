#!/usr/bin/env bash
declare -p _fa5db1cec69d83e1bb3898143fd1002c >/dev/null 2>&1 && return

_fa5db1cec69d83e1bb3898143fd1002c(){
  [[ ${BKITUSER+isset} == isset ]] || source "$(dirname -- "$(readlink -ne -- "${BASH_SOURCE[0]}")")/variables.sh"
	declare -r user="${BKITUSER:-$(id -nu)}"
  if [[ ${BKITCYGWIN+isset} == isset ]]
  then
    declare -r SID="$(wmic PATH win32_UserAccount where "Name = '$BKITUSER'" get SID|tr -d '\r'|tail -n+2|head -n1|sed -E 's/\s+$//')"
    declare homedir="$(WMIC PATH win32_UserProfile where "SID = '$SID'" get LocalPath|tr -d '\r'|tail -n+2|head -1|sed -E 's/\s+$//')"
    true ${homedir:="$( getent passwd "$user" | cut -d: -f6 )"} #This is a fallback
    homedir="$(cygpath -u "$homedir")"
  else
    declare homedir="$( getent passwd "$user" | cut -d: -f6 )"
  fi
  true ${homedir:="$HOME"}        #another fallback
  true ${homedir:="/home/$user"}  #yet another
  [[ -e $homedir ]] || mkdir -pv "$homedir"
	VARDIR="$homedir/.bkit/var"
	ETCDIR="$homedir/.bkit/etc"
	[[ -e /home/$user ]] || ln -svT "$homedir" "/home/$user"
}

_fa5db1cec69d83e1bb3898143fd1002c

mkdir -pv "$VARDIR"
mkdir -pv "$ETCDIR" 
