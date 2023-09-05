#!/usr/bin/env bash
#https://dataprotector.onlinebackup.com/Help/TSK/bk_commonexcludes.html

reg Query "HKLM\SYSTEM\CurrentControlSet\Control\BackupRestore\FilesNotToBackup"|
	sed -nE '/.*REG_MULTI_SZ\s+(.+$)/{
		s//\1/;
		s|\\0|\n|g;
		s|\s*(/s)?$||mg;
		s/%\w+%/\U&/g;
    s!\s*/s$!!;
		p
	}'