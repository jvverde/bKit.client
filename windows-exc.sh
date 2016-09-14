#!/bin/bash
FILE=$1
ALLUSERSPROFILE=$(cygpath "$ALLUSERSPROFILE")
WINDIR=$(cygpath "$WINDIR")
USERPROFILE=$(cygpath "$USERPROFILE"|sed "s|/$USERNAME|/*|")
APPDATA=$(cygpath "$APPDATA"|sed "s|/$USERNAME|/*|")
TEMP=$(cygpath "$TEMP"|sed "s|/$USERNAME|/*|")
TMP=$(cygpath "$TMP"|sed "s|/$USERNAME|/*|")
{
	[[ -n $LOCALAPPDATA ]] && LOCALAPPDATA=$(cygpath "$LOCALAPPDATA"|sed "s|/$USERNAME|/*|") && cat "$1"
	[[ -z $LOCALAPPDATA ]] && cat "$1" | sed /%LOCALAPPDATA%/d
}| sed "
	s|%ALLUSERSPROFILE%|$ALLUSERSPROFILE|;
	s|%USERPROFILE%|$USERPROFILE|;
	s|%WINDIR%|$WINDIR|;
	s|%LOCALAPPDATA%|$LOCALAPPDATA|;
	s|%APPDATA%|$APPDATA|;
	s|%TMP%|$TMP|;
	s|%TEMP%|$TEMP|;
	s|/cygdrive/./||
"
