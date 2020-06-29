#!/usr/bin/env bash
declare -p _8d84093ab1869faabb7124aab6d78829 >/dev/null 2>&1 && return

_8d84093ab1869faabb7124aab6d78829(){
  [[ ${BKITUSER+isset} == isset ]] || source "$(dirname -- "$(readlink -ne -- "${BASH_SOURCE[0]}")")/variables.sh"
	declare -r user="${BKITUSER:-$(id -nu)}"
  if [[ ${BKITCYGWIN+isset} == isset ]]
  then
    {
      declare -r SID="$(WMIC PATH win32_UserAccount where "Name = '$BKITUSER'" get SID|tr -d '\r'|tail -n+2|head -n1|sed -E 's/\s+$//')"
      declare homedir="$(WMIC PATH win32_UserProfile where "SID = '$SID'" get LocalPath|tr -d '\r'|tail -n+2|head -1|sed -E 's/\s+$//')"
      [[ ${BKITISADMIN+isset} == isset && -z $homedir ]] && {
        #This is a fallback
        homedir="$(WMIC PATH win32_UserProfile where "SID like 'S-1-5-21%%-500'" get LocalPath|tr -d '\r'|tail -n+2|head -1|sed -E 's/\s+$//')" 
        true ${homedir:="${ALLUSERSPROFILE+"$ALLUSERSPROFILE"/bkit-admin}"} #a hard-wired fallback
        true ${homedir:="$ProgramData/bkit-admin"} #In worst case homedir will be /bkit-admin
      }
      true ${homedir:="$( getent passwd "$user" | cut -d: -f6 )"} #This is another fallback
      homedir="$(cygpath -u "$homedir")"
    } 2>/dev/null
  else
    declare homedir="$( getent passwd "$user" | cut -d: -f6 )"
  fi
  true ${homedir:="$HOME"}        #another fallback
  true ${homedir:="/home/$user"}  #yet another
  [[ -e $homedir ]] || mkdir -pv "$homedir"
	declare -gx VARDIR="$homedir/.bkit/var"
	declare -gx ETCDIR="$homedir/.bkit/etc"
  #[[ $homedir == /home/$user ]] || mv "/home/$user" "/home/$user.old"
	#[[ -e /home/$user ]] || ln -svT "$homedir" "/home/$user"
  [[ "$(readlink -nm "$homedir")" != "$(readlink -nm "/home/$user")" ]] && {
    [[ -e /home/$user ]] && mv --backup=numbered "/home/$user" "/home/${user}.old"
    ln -svTf "$homedir" "/home/$user"
  }
} 

[[ ${VARDIR+x} == x && ${ETCDIR+y} == y && -e $VARDIR && -e $ETCDIR ]] && return

_8d84093ab1869faabb7124aab6d78829

mkdir -pv "$VARDIR"
mkdir -pv "$ETCDIR" 
