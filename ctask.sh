#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR
OS=$(uname -o|tr '[:upper:]' '[:lower:]')
exists() { type "$1" >/dev/null 2>&1;}
die() { echo -e "$@">&2; exit 1; }
usage(){
	die "Usage:\n\t$0 [-m|-h|-d|-w [every]]"
}
[[ $OS == cygwin || $UID -eq 0 ]] || exec sudo "$0" "$@"
[[ $OS == cygwin ]] && !(id -G|grep -qE '\b544\b') && {
	echo I am to going to runas Administrator
	cygstart -w --action=runas /bin/bash bash "$0" "$@" && exit
}
echo aqui $2
while [[ $1 =~ ^- ]]
do
	KEY="$1" && shift
	case "$KEY" in	
		-h|--hour)
			TYPE=HOURLY
			[[ "$1" =~ ^[0-9]+$ ]] && EVERY=$1 && shift 
		;;
		-m|--minute)
			TYPE=MINUTE
			[[ "$1" =~ ^[0-9]+$ ]] && EVERY=$1 && shift
		;;
		-d|--day)
			TYPE=DAILY
			[[ "$1" =~ ^[0-9]+$ ]] && EVERY=$1 && shift
		;;
		-w|--week)
			TYPE=WEEKLY
			[[ "$1" =~ ^[0-9]+$ ]] && EVERY=$1 && shift
		;;
		*)
			echo Unknow	option $KEY && usage
		;;		
	esac
done
