#!/usr/bin/env bash
SDIR="$(dirname -- "$(readlink -en -- "$0")")"               #Full DIR
source "$SDIR/lib/functions/all.sh"
[[ $UID -ne 0 ]] && exists sudo && exec sudo "$0" "$@"

#[[ $UID -eq 0 ]] && U=$(who am i | awk '{print $1}')
#USERID=$(id -u $U)
#GRPID=$(id -g $U)

exists CMD && {
	mktempdir RUNDIR
	BATCH="$RUNDIR/set$$.bat"
	DIR=$(cygpath -w "$SDIR")
	{
		echo Assoc .bkit=bkit
		echo Ftype bkit='"'$DIR\\bash.bat'" "'$SDIR/recovery.sh'" "%%1"'
	}> "$BATCH"
	CMD /C "$(cygpath -w "$BATCH")"
}
