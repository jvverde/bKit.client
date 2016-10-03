#!/bin/bash
die() { echo -e "$@" >&2; exit 1; }
exists() { type "$1" >/dev/null 2>&1;}
OS=$(uname -o|tr '[:upper:]' '[:lower:]')
[[ $UID -ne 0 ]] && exists sudo && exec sudo "$0" "$@"
SDIR="$(dirname "$(readlink -f "$0")")"               #Full DIR
exists apt-get && {
	apt-get update
	apt-get install -y sqlite3
}

[[ $UID -eq 0 ]] && U=$(who am i | awk '{print $1}')
USERID=$(id -u $U)
GRPID=$(id -g $U)

for DIR in logs run cache
do
  [[ -d "$SDIR/$DIR" ]] || {
    mkdir -pv "$SDIR/$DIR" && chown -v $USERID:$GRPID "$SDIR/$DIR"
  }
done
exists CMD && {
	BATCH="$SDIR/run/set$$.bat"
	DIR=$(cygpath -w "$SDIR")
	{
		echo Assoc .bkit=bkit
		echo Ftype bkit='"'$DIR\\bash.bat'" "'$SDIR/recovery.sh'" "%%1"'
	}> "$BATCH"
	CMD /C "$(cygpath -w "$BATCH")"
	rm -f $BATCH
}
echo Compile excludes file
bash "$SDIR/make-excludes.sh"