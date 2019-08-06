#!/usr/bin/env bash
SDIR=$(dirname "$(readlink -f "$0")")       #Full DIR

SDRIVE=$SYSTEMDRIVE
[[ -n $SDRIVE ]] || SDRIVE=$(cmd /C echo %SystemDrive%|sed -E 's#\r##')
set -f
while read -r LINE
do
	[[ $LINE =~ ^# || $LINE =~ ^[[:space:]]*$ ]] && continue

	DIR=$(cmd /C "echo $LINE"|sed -E 's#\r##')
	[[ $DIR =~ ^\\ ]] && DIR="$SDRIVE$DIR"
	DIR=$(cygpath -u "$DIR")
	[[ -z $DIR ]] && {
		LINE=$(echo $LINE | sed -E 's#%([^%]+)%#$\U\1#g')
		DIR=$(sh -c "echo $LINE")
		[[ $DIR =~ ^\\ ]] && DIR="$SDRIVE$DIR"
		DIR=$(cygpath -u "$DIR")
	}
	[[ -n $DIR ]] && {
		[[ $DIR =~ ^/ ]] && echo -/ $DIR || echo - $DIR
	}
done

