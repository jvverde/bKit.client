#!/usr/bin/env bash
[[ ${VARDIR+x} == x && ${ETCDIR+y} == y && -e $VARDIR && -e $ETCDIR ]] && [[ ! ${1+$1} =~ ^-f ]] && return


_bkit_find_dirs(){
  declare mylocation="$(dirname -- "$(readlink -ne -- "${BASH_SOURCE[0]}")")"
  source "$mylocation/variables.sh" ${1:+"$@"}

  declare -r user="${BKITUSER:-$(id -nu)}"

  if [[ ${BKITCYGWIN+isset} == isset ]]
  then
    {
      declare -r SID="$(WMIC PATH win32_UserAccount where "Name = '$BKITUSER'" get SID|tr -d '\r'|tail -n+2|head -n1|sed -E 's/\s+$//')"
      declare homedir="$(WMIC PATH win32_UserProfile where "SID = '$SID'" get LocalPath|tr -d '\r'|tail -n+2|head -1|sed -E 's/\s+$//')"
      [[ ${BKITISADMIN+isset} == isset && -z $homedir ]] && {
        #This is a fallback
        homedir="$(WMIC PATH win32_UserProfile where "SID like 'S-1-5-21%%-500'" get LocalPath|tr -d '\r'|tail -n+2|head -1|sed -E 's/\s+$//')" 
        #true "${homedir:="$(WMIC PATH win32_UserProfile where "SID like 'S-1-5-18'" get LocalPath|tr -d '\r'|tail -n+2|head -1|sed -E 's/\s+$//')"}" #a hard-wired fallback
        true "${homedir:="${ALLUSERSPROFILE+"$ALLUSERSPROFILE"/bkit-admin}"}" #a hard-wired fallback
        true "${homedir:="$ProgramData/bkit-admin"}" #In worst case homedir will be /bkit-admin
      }
      true "${homedir:="$( getent passwd "$user" | cut -d: -f6 )"}" #This is another fallback
      homedir="$(cygpath -u "$homedir")"
    } 2>/dev/null
  else
    declare homedir="$( getent passwd "$user" | cut -d: -f6 )"
  fi
  true "${homedir:="$HOME"}"        #another fallback
  true "${homedir:="/home/$user"}"  #yet another
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


${__SOURCED__:+return} #Intended for shellspec tests

_bkit_find_dirs ${1:+"$@"}

mkdir -pv "$VARDIR"
mkdir -pv "$ETCDIR" 

if [[ ${BASH_SOURCE[0]} == "$0" ]]
then
  echo VARDIR="$VARDIR"
  echo ETCDIR="$ETCDIR"
fi