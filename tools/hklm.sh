#!/bin/bash
SDIR="$(dirname "$(readlink -f "$0")")"	
reg Query "HKLM\SYSTEM\CurrentControlSet\Control\BackupRestore\FilesNotToBackup"|
	sed -nE '/.*REG_MULTI_SZ\s+(.+$)/{
		s//\1/;
		s|\\0|\n|g;
		s|\s*(/s)?$||mg;
		s/%\w+%/\U&/mg;
		s|\\|/|g;
		p
	}'| 
	"$SDIR/windows-exc.sh" -|
	xargs -rI{} cygpath -u "{}"|
	sed 's|^/cygdrive/.||'
