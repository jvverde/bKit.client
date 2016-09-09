#!/bin/bash
#find "$1" -maxdepth 2 "$(echo $(cat conf/e.txt |sed -e /^#/d -e 's/.*/ -path "*&*" -prune -o /'))" -type f -print
EXC=$(cat conf/excludes.txt|
	sed -e /^#/d -e 's/ /?/g'|
	sed -E "
		/^[^/]*$/{s%%-name '&'%p;d}
		/^([^/]*)[/]$/{s%%-name '\1' -type d%p;d}
		/^[/](.*[^/])$/{s%%-wholename '$1\1'%p;d}
		/^[/](.*)[/]$/{s%%-path '$1\1' -type d%p;d}
		/^(.*)[/]$/{s%%-path '\1' -type d%p;d}
		/^[*].*[*]$/{s%%-path '&'%p;d}
		/^[*].*[^*]$/{s%%-path '&/*'%p;d}
		/^[^*].*[*]$/{s%%-path '*/&'%p;d}
		s%.*/.*%-path '*&*'%
	"|
	sed 's/^\s*-.*$/& -prune -o/'|
	tr '\n' ' '
) 
echo bash -c "find $1 -maxdepth 2 $EXC -type f -print"
bash -c "find $1 $EXC -type f -print"