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
	//https://cygwin.com/ml/cygwin/2015-02/msg00057.html
	echo I am to going to runas Administrator
	cygstart -w --action=runas /bin/bash bash "$0" "$@" && exit
}
ONALL='*'
MINUTE=ONALL
HOUR=ONALL
DAYOFMONTH=ONALL
MONTH=ONALL
DAYOFWEEK=ONALL
let ONMINUTES=$RANDOM%60
let ONHOURS=$RANDOM%24
let ONDAYOFWEEK=$RANDOM%7
let ONDAYOFMONTH=1+$RANDOM%28
let ONMONTHS=1+$RANDOM%12
while [[ $1 =~ ^- ]]
do
	KEY="$1" && shift
	case "$KEY" in	
		-m|--minute)
			[[ $# -gt 1 && "$1" =~ ^[0-9,*/-]+$ ]] && ONMINUTES="$1" && shift && MINUTE=ONMINUTES 
		;;
		-h|--hour)
			[[ $# -gt 1 && "$1" =~ ^[0-9,*/-]+$ ]] && ONHOURS="$1" && shift && HOUR=ONHOURS
			MINUTE=ONMINUTES
		;;
		-d|--day)
			[[ $# -gt 1 && "$1" =~ ^[0-9,*/-]+$ ]] && ONDAYOFMONTH="$1" && shift && DAYOFMONTH=ONDAYOFMONTH
			MINUTE=ONMINUTES
			HOUR=ONHOURS
		;;
		-w|--week)
			[[ $# -gt 1 && "$1" =~ ^[0-9,*/-]+$ ]] && ONDAYOFWEEK="$1" && shift
			MINUTE=ONMINUTES
			HOUR=ONHOURS
			DAYOFWEEK=ONDAYOFWEEK
		;;
		-M|--monthly)
			[[ $# -gt 1 && "$1" =~ ^[0-9,*/-]+$ ]] && ONMONTHS=$1 && shift && MONTH=ONMONTHS
			MINUTE=ONMINUTES
			HOUR=ONHOURS
			DAYOFMONTH=ONDAYOFMONTH
		;;
		*)
			echo Unknow	option $KEY && usage
		;;		
	esac
done


BACKUPPATH=$(readlink -e "$1")
NAME=$2

IFS='|' read UUID DIR <<<$(bash "$SDIR/getUUID.sh" "$BACKUPPATH" 2>/dev/null)

[[ -z $NAME ]] && exists lsblk && NAME=$(lsblk -Pno LABEL,UUID|fgrep "UUID=\"$UUID\""|grep -Po '(?<=LABEL=")([^"]|\\")*(?=")')
LOGSDIR=$SDIR/logs$BACKUPPATH
[[ -d $LOGSDIR ]] || mkdir -p "$LOGSDIR"

{
	crontab -l 2>/dev/null
	echo "${!MINUTE} ${!HOUR} ${!DAYOFMONTH} ${!MONTH} ${!DAYOFWEEK} /bin/bash '$SDIR/backup.sh' --uuid '$UUID' --dir '$DIR' --log '$LOGSDIR/${NAME:-_}-$UUID'"
} | sort -u | crontab

#show what is scheduled 
crontab -l


