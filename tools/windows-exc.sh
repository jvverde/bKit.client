#!/bin/bash
set -f
FILE=${1:--}
getcivar(){	
	VAR=$(set|grep -Pio "^$1(?==)") && cygpath ${!VAR}|sed 's|^/cygdrive/./|/cygdrive/?/|' || echo "%$1%"
}
u2A(){
	echo "$@"|sed "s|/$USERNAME|*|"	
}
USERNAME=$(getcivar USERNAME)
SYSTEMROOT=$(getcivar SYSTEMROOT)
PROGRAMDATA=$(getcivar PROGRAMDATA)
ALLUSERSPROFILE=$(getcivar ALLUSERSPROFILE)
WINDIR=$(getcivar WINDIR)
USERPROFILE=$(getcivar USERPROFILE)
APPDATA=$(getcivar APPDATA)
LOCALAPPDATA=$(getcivar LOCALAPPDATA)
TEMP=$(getcivar TEMP)
TMP=$(getcivar TMP)

USERPROFILE=$(u2A "$USERPROFILE")
APPDATA=$(u2A "$APPDATA")
LOCALAPPDATA=$(u2A "$LOCALAPPDATA")
TEMP=$(u2A "$TEMP")
TMP=$(u2A "$TMP")
cat "$FILE" | sed -E "
	s|^([A-Za-z]:)?/|/cygdrive/?/|;
	s|^%SYSTEMROOT%|$SYSTEMROOT|;
	s|^%PROGRAMDATA%|$PROGRAMDATA|;
	s|^%ALLUSERSPROFILE%|$ALLUSERSPROFILE|;
	s|^%USERPROFILE%|$USERPROFILE|;
	s|^%WINDIR%|$WINDIR|;
	s|^%LOCALAPPDATA%|$LOCALAPPDATA|;
	s|^%APPDATA%|$APPDATA|;
	s|^%TMP%|$TMP|;
	s|^%TEMP%|$TEMP|;
	s|^%[^%]*%||;
"
