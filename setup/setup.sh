#!/usr/bin/env bash
sdir="$(dirname -- "$(readlink -en -- "$0")")"               #Full DIR
sdir="${sdir%/client*}/client"

source "$sdir/lib/functions/variables.sh"
source "$sdir/lib/functions/messages.sh"
source "$sdir/lib/functions/mktempdir.sh"

[[ $UID -ne 0 ]] && exists sudo && exec sudo "$0" "$@"

#[[ $UID -eq 0 ]] && U=$(who am i | awk '{print $1}')
#USERID=$(id -u $U)
#GRPID=$(id -g $U)

[[ $OS == cygwin ]] && {
	declare -r nsswitch="$(find "$sdir" -type f -path '*/cygwin/etc/nsswitch.conf' -print -quit)"  
	[[ -e $nsswitch ]] || warn 'cygwin/etc/nsswitch does not exits'
	sed -i '/^db_home/d' "$nsswitch"
	echo 'db_home: windows' >> "$nsswitch"

	exists CMD && {
		mktempdir RUNDIR
		BATCH="$RUNDIR/set$$.bat"
		DIR=$(cygpath -w "$sdir")
		{
			echo Assoc .bkit=bkit
			echo Ftype bkit='"'$DIR\\bash.bat'" "'$sdir/recovery.sh'" "%%1"'
		}> "$BATCH"
		CMD /C "$(cygpath -w "$BATCH")"
	}
}