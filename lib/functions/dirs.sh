#!/usr/bin/env bash
declare -p _fa5db1cec69d83e1bb3898143fd1002c >/dev/null 2>&1 && return

_fa5db1cec69d83e1bb3898143fd1002c(){
  [[ ${BKITUSER+isset} == isset ]] || source "$(dirname -- "$(readlink -ne -- "${BASH_SOURCE[0]}")")/variables.sh"
	declare -r user="${BKITUSER:-$(id -nu)}"
  if [[ ${BKITCYGWIN+isset} == isset ]]
  then
    declare -r SID="$(wmic PATH win32_UserAccount where "Name = '$BKITUSER'" get SID|tr -d '\r'|tail -n+2|head -n1|sed -E 's/\s+$//')"
    declare homedir="$(WMIC PATH win32_UserProfile where "SID = '$SID'" get LocalPath|tr -d '\r'|tail -n+2|head -1|sed -E 's/\s+$//')"
    [[ ${BKITISADMIN+isset} == isset && -z $homedir ]] && {
      homedir="$(WMIC PATH win32_UserProfile where "SID like 'S-1-5-21%%-500'" get LocalPath|tr -d '\r'|tail -n+2|head -1|sed -E 's/\s+$//')" #This is a fallback
      #true ${homedir:="$(WMIC PATH win32_UserProfile where "SID = 'S-1-5-18'" get LocalPath|tr -d '\r'|tail -n+2|head -1|sed -E 's/\s+$//')"} #This is a fallback
      true ${homedir:="$ALLUSERSPROFILE/bkit-admin"}
      true ${homedir:="$ProgramData/bkit-admin"}
    }
    true ${homedir:="$( getent passwd "$user" | cut -d: -f6 )"} #This is another fallback
    homedir="$(cygpath -u "$homedir")"
  else
    declare homedir="$( getent passwd "$user" | cut -d: -f6 )"
  fi
  true ${homedir:="$HOME"}        #another fallback
  true ${homedir:="/home/$user"}  #yet another
  [[ -e $homedir ]] || mkdir -pv "$homedir"
	VARDIR="$homedir/.bkit/var"
	ETCDIR="$homedir/.bkit/etc"
  #[[ $homedir == /home/$user ]] || mv "/home/$user" "/home/$user.old"
	#[[ -e /home/$user ]] || ln -svT "$homedir" "/home/$user"
  [[ "$(readlink -nm "$homedir")" != "$(readlink -nm "/home/$user")" ]] && {
    [[ -e /home/$user ]] && mv --backup=numbered "/home/$user" "/home/${user}.old"
    ln -svTf "$homedir" "/home/$user"
  }
}

_fa5db1cec69d83e1bb3898143fd1002c

mkdir -pv "$VARDIR"
mkdir -pv "$ETCDIR" 
