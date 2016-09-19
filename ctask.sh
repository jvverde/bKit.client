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
	cygAT -w --action=runas /bin/bash bash "$0" "$@" && exit
}
ATALL='*'
MINUTE=ATALL
HOUR=ATALL
DAY=ATALL
MONTH=ATALL
DAYOFWEEK=ATALL
let ATMINUTES=$RANDOM%60
let ATHOUR=$RANDOM%24
let ATDAYOFWEEK=$RANDOM%7
let ATDAYOFMONTH=1+$RANDOM%28
let ATMONTH=1+$RANDOM%12
while [[ $1 =~ ^- ]]
do
	KEY="$1" && shift
	case "$KEY" in	
		-m|--minute)
			TYPE=MINUTE
			[[ "$1" =~ ^[0-9,*/-]+$ ]] && ATMINUTES="$1" && shift && MINUTE=ATMINUTES 
		;;
		-h|--hour)
			TYPE=HOURLY
			[[ "$1" =~ ^[0-9,*/-]+$ ]] && HOURS=$1 && shift && HOUR=HOURS
			MINUTE=ATMINUTES
		;;
		-d|--day)
			TYPE=DAILY
			[[ "$1" =~ ^[0-9,*/-]+$ ]] && DAYS=$1 && shift && DAY=DAYS
			MINUTE=ATMINUTE
			HOUR=ATHOUR
		;;
		-w|--week)
			TYPE=WEEKLY
			[[ "$1" =~ ^[0-9,*/-]+$ ]] && WEEKDAYS=$1 && shift && WEEK=WEEKDAYS
			MINUTE=ATMINUTE
			HOUR=ATHOUR
			DAYOFWEEK=ATDAYOFWEEK
		;;
		-M|--monthly)
			TYPE=MONTHLY
			[[ "$1" =~ ^[0-9,*/-]+$ ]] && MONTHS=$1 && shift && MONTH=MONTHS
			MINUTE=ATMINUTE
			HOUR=ATHOUR
			DAYOFWEEK=ATALL
			DAY=ATDAYOFMONTH
		;;
		-sm|--startminute)
			[[ "$1" =~ ^[0-9]+$ && "$1" -le 59 ]] && ATMINUTE=$1 && shift	
		;;
		-sh|--starthour)
			[[ "$1" =~ ^[0-9]+$ && "$1" -le 23 ]] && ATHOUR=$1 && shift
		;;
		-sdow|--startdayofweek)
			[[ "$1" =~ ^[0-9]+$ && "$1" -le 6 ]] && ATDAYOFWEEK=$1 && shift
		;;
		-sdom|--startdayofmonth)
			[[ "$1" =~ ^[0-9]+$ && "$1" -le 31 ]] && ATDAYOFMONTH=$1 && shift
		;;
		*)
			echo Unknow	option $KEY && usage
		;;		
	esac
done


BACKUPPATH=$1
IFS='|' read UUID DIR <<<$(bash "$SDIR/getUUID.sh" $BACKUPPATH 2>/dev/null)

echo $UUID
echo $DIR

echo "${!MINUTE} ${!HOUR} ${!DAY} ${!MONTH} ${!DAYOFWEEK}"
crontab -l 2>/dev/null > ".tmp.$$.contrab"

rm -f ".tmp.$$.contrab" 


