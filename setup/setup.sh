#!/usr/bin/env bash
declare -r sdir="$(dirname -- "$(readlink -en -- "$0")")"               #Full DIR
declare -r client="${sdir%/setup*}"

source "$client/lib/functions/variables.sh"
source "$client/lib/functions/messages.sh"
source "$client/lib/functions/mktempdir.sh"

[[ $UID -ne 0 ]] && exists sudo && exec sudo "$0" "$@"

#[[ $UID -eq 0 ]] && U=$(who am i | awk '{print $1}')
#USERID=$(id -u $U)
#GRPID=$(id -g $U)

[[ $1 =~ --proxy= ]] &&  {
 declare -r proxy="${1#*=}" && shift
 export http_proxy="http://$proxy"
 export https_proxy="https://$proxy"
}

[[ $OS == cygwin ]] && {
	bash "$sdir"/setup-apt.sh
	bash "$sdir"/apt-cyg.sh "$sdir"/cyg-packages.lst
	bash "$sdir"/setup-shadowspwan.sh
	bash "$sdir"/setup-paexec.sh
	

	declare -r nsswitch="$(find "$client" -type f -path '*/cygwin/etc/nsswitch.conf' -print -quit)"  
	[[ -e $nsswitch ]] || warn 'cygwin/etc/nsswitch does not exits'
	sed -i '/^db_home/d' "$nsswitch"
	echo 'db_home: windows' >> "$nsswitch"
	
}