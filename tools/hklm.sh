#!/bin/bash
SDIR="$(dirname "$(readlink -f "$0")")"	
reg Query "HKLM\SYSTEM\CurrentControlSet\Control\BackupRestore\FilesNotToBackup"|
	fgrep REG_MULTI_SZ|
	cut -f3|
	sed -E '
		s|\\0|\n|g;
		s|\s*(/s)?$||mg;
		s/%\w+%/\U&/;
		s|\\|/|g
	'| 
	"$SDIR/windows-exc.sh" -|
	xargs -rI{} cygpath -u "{}"|
	sed 's|^/cygdrive/.||'
