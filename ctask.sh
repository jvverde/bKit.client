#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR
OS=$(uname -o|tr '[:upper:]' '[:lower:]')
exists() { type "$1" >/dev/null 2>&1;}
die() { echo -e "$@">&2; exit 1; }
usage(){
	die "Usage:\n\t$0 [-m|-h|-d|-w [every]] dirs"
}
[[ $OS == cygwin || $UID -eq 0 ]] || exec sudo "$0" "$@"
[[ $OS == cygwin ]] && !(id -G|grep -qE '\b544\b') && {
	#https://cygwin.com/ml/cygwin/2015-02/msg00057.html
	echo I am to going to runas Administrator
	cygstart -w --action=runas /bin/bash bash "$0" "$@" && exit
}
ONALL='*'
MINUTE=ONALL
HOUR=ONALL
DAYOFMONTH=ONALL
MONTH=ONALL
DAYOFWEEK=ONALL
EVERY=1 #for windows only
START=$(date -u)
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
			SCHTYPE=MINUTE
			[[ $# -gt 1 ]] || continue
			[[ "$1" =~ ^[0-9,*/-]+$ ]] && (( $1 < 1440 && $1 > 0 )) && EVERY=$1
			[[ "$1" =~ ^[0-9,*/-]+$ ]] && ONMINUTES="$1" && shift && MINUTE=ONMINUTES
		;;
		-h|--hour)
			SCHTYPE=HOURLY
			[[ $# -gt 1 ]] || continue
			[[ "$1" =~ ^[0-9,*/-]+$ ]] && (( $1 < 24 && $1 > 0 )) && EVERY=$1
			[[ "$1" =~ ^[0-9,*/-]+$ ]] && ONHOURS="$1" && shift && HOUR=ONHOURS
			MINUTE=ONMINUTES
		;;
		-d|--day)
			SCHTYPE=DAILY
			[[ $# -gt 1 ]] || continue
			[[ "$1" =~ ^[0-9,*/-]+$ ]] && (( $1 < 366 && $1 > 0 )) && EVERY=$1
			[[ "$1" =~ ^[0-9,*/-]+$ ]] && ONDAYOFMONTH="$1" && shift && DAYOFMONTH=ONDAYOFMONTH
			MINUTE=ONMINUTES
			HOUR=ONHOURS
		;;
		-w|--week)
			SCHTYPE=WEEKLY
			[[ $# -gt 1 ]] || continue
			(( $1 < 53 && $1 > 0 )) && EVERY=$1
			[[ "$1" =~ ^[0-9,*/-]+$ ]] && ONDAYOFWEEK="$1" && shift
			MINUTE=ONMINUTES
			HOUR=ONHOURS
			DAYOFWEEK=ONDAYOFWEEK
		;;
		-M|--monthly)
			SCHTYPE=MONTHLY
			[[ $# -gt 1 ]] || continue
			[[ "$1" =~ ^[0-9,*/-]+$ ]] && (( $1 < 12 && $1 > 0 )) && EVERY=$1
			[[ "$1" =~ ^[0-9,*/-]+$ ]] && ONMONTHS=$1 && shift && MONTH=ONMONTHS
			MINUTE=ONMINUTES
			HOUR=ONHOURS
			DAYOFMONTH=ONDAYOFMONTH
		;;
		-n|--name)
			NAME="$1" && shift
		;;
		-s|--start)
			START=$(date -d "$1" -u) && shift || die Wrong date format
		;;
		-- )
            while [[ $1 =~ ^- ]]
            do
                RSYNCOPTIONS+=("$1")
                shift
            done
        ;;
		*)
			echo Unknow	option $KEY && usage
		;;
	esac
done


LOGSDIR=$SDIR/logs
[[ -d $LOGSDIR ]] || mkdir -pv "$LOGSDIR"


[[ -n $DIR ]] && FLATDIR=${DIR//[^a-zA-Z0-9_-]/_} || FLATDIR=ROOT

if [[ $OS == cygwin ]]
then
	DOSBASH=$(cygpath -w "$BASH")
	TASKDIR="$SDIR/schtasks"
	[[ -d $TASKDIR ]] || mkdir -pv "$TASKDIR"
	TASKNAME="BKIT-${NAME:-$(date +%Y-%m-%dT%H-%M-%S)}"
	TASKBATCH="${TASKDIR}/${TASKNAME}.bat"
	#[[ -e $TASKBATCH ]] && die $TASKBATCH already exists
	for BACKUPDIR in "$@"
	do
		BACKUPPATH=$(cygpath -u "$(readlink -e "$BACKUPDIR")")
		IFS='|' read UUID DIR <<<$(bash "$SDIR/getUUID.sh" "$BACKUPPATH" 2>/dev/null)
		LOGFILE=$LOGSDIR/$TASKNAME.$UUID.$(echo $DIR|md5sum|awk '{print $1}').log
		CMD='"'${DOSBASH}.exe'" "'${SDIR}/snapshot.sh'" --uuid "'$UUID'" --dir "'$DIR'" --log "'$LOGFILE'" -- '"${RSYNCOPTIONS[@]}"
		echo REM Backup $(cygpath -w "$BACKUPDIR") "($BACKUPPATH)"
		echo REM Logs in $LOGFILE
		echo $CMD
	done > "$TASKBATCH"
	exit
	TASCMD='"'$(cygpath -w "$TASKBATCH")'"'
	ST=$(date -d "$START" +"%H:%M:%S")
	#SD=$(date -d "$START" +"%d/%m/%Y")
	#http://www.robvanderwoude.com/datetimentparse.php
	#schtasks /CREATE /RU "SYSTEM" /SC $SCHTYPE /MO $EVERY /ST "$ST" /SD "$SD" /TN "$TASKNAME" /TR "$TASCMD"
	let FORMAT=$(REG QUERY "HKCU\Control Panel\International"|fgrep -i "iDate"|grep -Po "\d")
	(($FORMAT == 0)) && SD=$(date -d "$START" +"%m/%d/%Y")
	(($FORMAT == 1)) && SD=$(date -d "$START" +"%d/%m/%Y")
	(($FORMAT == 2)) && SD=$(date -d "$START" +"%Y/%m/%d")
	schtasks /CREATE /RU "SYSTEM" /SC $SCHTYPE /MO $EVERY /ST "$ST" /SD "$SD" /TN "$TASKNAME" /TR "$TASCMD"
	schtasks /QUERY|fgrep BKIT
else
	[[ -z $NAME ]] && exists lsblk && NAME=$(lsblk -Pno LABEL,UUID|fgrep "UUID=\"$UUID\""|grep -Po '(?<=LABEL=")([^"]|\\")*(?=")')
	LOGFILE="$LOGSDIR/${NAME:-_}-$UUID.${FLATDIR}.log"

	{
		crontab -l 2>/dev/null
		echo "${!MINUTE} ${!HOUR} ${!DAYOFMONTH} ${!MONTH} ${!DAYOFWEEK} /bin/bash '$SDIR/backup.sh' --uuid '$UUID' --dir '$DIR' --log '$LOGSDIR/${NAME:-_}-$UUID'"
	} | sort -u | crontab

	#show what is scheduled
	crontab -l
fi



