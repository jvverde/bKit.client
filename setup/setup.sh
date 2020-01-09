#!/usr/bin/env bash
declare -r sdir="$(dirname -- "$(readlink -en -- "$0")")"               #Full DIR
declare -r client="${sdir%/client*}/client"

source "$client/lib/functions/variables.sh"
source "$client/lib/functions/messages.sh"
source "$client/lib/functions/mktempdir.sh"

[[ $UID -ne 0 ]] && exists sudo && exec sudo "$0" "$@"

#[[ $UID -eq 0 ]] && U=$(who am i | awk '{print $1}')
#USERID=$(id -u $U)
#GRPID=$(id -g $U)

[[ $OS == cygwin ]] && {
	bash "$sdir"/setup-apt.sh
	bash "$sdir"/apt-cyg.sh "$sdir"/cyg-packages.lst
	bash "$sdir"/setup-shadowspwan.sh
	bash "$sdir"/setup-sysinternals.sh
	

	declare -r nsswitch="$(find "$client" -type f -path '*/cygwin/etc/nsswitch.conf' -print -quit)"  
	[[ -e $nsswitch ]] || warn 'cygwin/etc/nsswitch does not exits'
	sed -i '/^db_home/d' "$nsswitch"
	echo 'db_home: windows' >> "$nsswitch"
	
	exists CMD && {
		mktempdir RUNDIR
		BATCH="$RUNDIR/set$$.bat"
		DIR=$(cygpath -w "$client")
		{
			echo Assoc .bkit=bkit
			echo Ftype bkit='"'$DIR\\bash.bat'" "'$client/recovery.sh'" "%%1"'
		}> "$BATCH"
		CMD /C "$(cygpath -w "$BATCH")"
	}
}