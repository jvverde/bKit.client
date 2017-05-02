#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR
OS=$(uname -o|tr '[:upper:]' '[:lower:]')
exists() { type "$1" >/dev/null 2>&1;}
die() { echo -e "$@">&2; exit 1; }
warn() { echo -e "$@">&2;}
usage(){
	die "Usage:\n\t$0 [-m|-h|-d|-w [every]] dirs"
}

# [[ $OS == cygwin || $UID -eq 0 ]] || exec sudo "$0" "$@"
# [[ $OS == cygwin ]] && !(id -G|grep -qE '\b544\b') && {
# 	#https://cygwin.com/ml/cygwin/2015-02/msg00057.html
# 	echo I am to going to runas Administrator
# 	cygstart -w --action=runas /bin/bash bash "$0" "$@" && exit
# }

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
FILTERS=()
OLDIFS=$IFS
IFS="
"
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
		-f|--filter)
			FILTERS+=("$1")
    ;;
    -f=*|--filter=*)
			FILTERS+=("${KEY#*=}")
    ;;
    --filters-from)
			[[ -e $1 ]] || die "Can't find '$1'"
			FILTERS+=( $(cat "$1") )
		;;
    --filters-from=*)
			FILE="${KEY#*=}"
			[[ -e $FILE ]] || die "Can't find $FILE"
			FILTERS+=( $(cat "$FILE") )
		;;
		--install)
			INSTALL="I"
		;;
		--force)
			FORCE="F"
		;;
		*)
			echo Unknow	option $KEY && usage
		;;
	esac
done

[[ $# -eq 0 ]] && usage

IFS=$OLDIFS

CURRENTTIME=$(date +%Y-%m-%dT%H-%M-%S)
FILTERDIR="$SDIR/filters"
[[ -d $FILTERDIR ]] || mkdir -pv "$FILTERDIR"

TASKNAME="BKIT-${NAME:-$CURRENTTIME}"

TASKDIR="$SDIR/cronjobs"
[[ $OS == cygwin ]] && TASKDIR="$SDIR/schtasks"

[[ -d $TASKDIR ]] || mkdir -pv "$TASKDIR"
JOBFILE="${TASKDIR}/${TASKNAME}.sh"
[[ $OS == cygwin ]] && JOBFILE="${TASKDIR}/${TASKNAME}.bat"

[[ -e $JOBFILE && -z $FORCE ]] && die "'$JOBFILE' already exists"
:> "$JOBFILE"

#RDIR=$(realpath -m --relative-to="$TASKDIR" "$SDIR")
RDIR="$SDIR"

[[ $OS == cygwin ]] && {
	RDIR=$(realpath -m --relative-to="$TASKDIR" "$SDIR")
	WBASH=$(cygpath -w "$BASH")
	DOSBASH=$(realpath --relative-to="$(cygpath -w "$TASKDIR")" "$WBASH")
	DOSBASH=${DOSBASH%.exe} #just in case
	CMD='"'${DOSBASH}.exe'" "'${RDIR}/skit.sh'"'
	echo '@echo OFF'> "$JOBFILE"
}


declare -A ROOTS
declare -A ROOTOF
declare -A RPATHS

for DIR in "$@"
do
    FULL=$(readlink -ne "$DIR") || { warn $DIR "doesn't exists" && continue ;}
    exists cygpath && FULL=$(cygpath -u "$FULL")
    ROOT=$(stat -c%m "$FULL")
    ROOTS["$ROOT"]=1
    REL=${FULL#$ROOT}	#path relative to root
    ROOTOF["$FULL"]="$ROOT"
    RPATHS["$FULL"]="$REL"
done

for ROOT in ${!ROOTS[@]}
do
	ROOTFILTERS=()
	BACKUPDIR=()
  for DIR in "${!ROOTOF[@]}"
  do
      [[ $ROOT == ${ROOTOF[$DIR]} ]] && BACKUPDIR+=( "\"${RPATHS["$DIR"]}\"" )
  done
  [[ ${#BACKUPDIR[@]} -gt 0 ]] || continue
  #echo ROOT:$ROOT
  for F in "${FILTERS[@]}"
  do
  	#echo F:$F
  	#DIR=${F:2}
  	DIR=${F#* }
  	P=${F%% *}
  	set -f
  	exists cygpath && [[ $DIR =~ ^[a-zA-Z]: || $DIR =~ \\ ]] && DIR=$(cygpath -u "$DIR")

  	#echo B:$DIR
  	[[ ! $DIR =~ ^/ ]] && ROOTFILTERS+=( "${P} $DIR" ) && continue #if not start on root
  	BASE=${DIR%\**}
		until [[ -d $BASE ]]
		do
			BASE=$(dirname "$BASE")
		done
  	R=$(stat -c%m "$BASE")
  	[[ $R == $ROOT ]] && ROOTFILTERS+=( "${P} $DIR" ) #only filters with same mountpoint
  done
	#echo "${ROOTFILTERS[@]}"

	UUID=$(bash "$SDIR/getUUID.sh" "$ROOT")
	[[ $UUID == _ ]] && continue

	DRIVE=${ROOT//\//_}
	[[ $OS == cygwin ]] && {
		DRIVE=$(cygpath -w "$ROOT")
		DRIVE=${DRIVE:0:1}
		DRIVE=${DRIVE,}
	}

	FILTERNAME="${TASKNAME}-${DRIVE}-${UUID}.lst"
	FILTERFILE="${FILTERDIR}/$FILTERNAME"

	echo "#Filter rules used by cronjob $JOBFILE. Don't remove this file" > "$FILTERFILE"
	[[ $OS == cygwin ]] && echo "#Filter rules used in '$(cygpath -w "$JOBFILE")'. Don't remove this file" > "$FILTERFILE"

	for F in "${ROOTFILTERS[@]}"
	do
		echo "$F"
	done >> "$FILTERFILE"
	LOGDIR="$RDIR/logs/${DRIVE,}/${TASKNAME,,}"
	OPTIONS=(
		'--no-ask'
		'--uuid "'$UUID'"'
		'--logdir "'$LOGDIR'"'
		'--compile'
		'--notify'
	)

	#FILTERLOCATION=$(realpath -m --relative-to="$TASKDIR" "$FILTERFILE")
	FILTERLOCATION="$FILTERFILE"

	if [[ $OS == cygwin ]]
	then
		FILTERLOCATION=$(realpath -m --relative-to="$TASKDIR" "$FILTERFILE")
		{
			echo REM Backup of "${BACKUPDIR[@]}" on DRIVE $(cygpath -w "$ROOT")
			echo REM Logs on folder $LOGDIR
			echo 'pushd "%~dp0"'
			echo $CMD "${OPTIONS[@]}"  -- --filter='". '$FILTERLOCATION'"' "${BACKUPDIR[@]}"
			echo 'popd'
		} >> "$JOBFILE"
	else
		{
			echo "#Backup of [${BACKUPDIR[@]}] under $ROOT"
			echo "#Logs on folder $LOGDIR"
			echo 'pushd "$(dirname "$(readlink -f "$0")")"'
			echo "/bin/bash \"$SDIR/skit.sh\"" "${OPTIONS[@]}"  -- --filter='". '$FILTERLOCATION'"' "${BACKUPDIR[@]}"
			echo 'popd'
		} >> "$JOBFILE"
	fi
done
if [[ $OS == cygwin ]]
then
	echo "Create a batch file in $JOBFILE"
	[[ -n $INSTALL ]] && {
		TASCMD='"'$(cygpath -w "$JOBFILE")'"'
		ST=$(date -d "$START" +"%H:%M:%S")
		#http://www.robvanderwoude.com/datetimentparse.php
		#schtasks /CREATE /RU "SYSTEM" /SC $SCHTYPE /MO $EVERY /ST "$ST" /SD "$SD" /TN "$TASKNAME" /TR "$TASCMD"
		let FORMAT=$(REG QUERY "HKCU\Control Panel\International"|fgrep -i "iDate"|grep -Po "\d")
		(($FORMAT == 0)) && SD=$(date -d "$START" +"%m/%d/%Y")
		(($FORMAT == 1)) && SD=$(date -d "$START" +"%d/%m/%Y")
		(($FORMAT == 2)) && SD=$(date -d "$START" +"%Y/%m/%d")
		schtasks /CREATE /RU "SYSTEM" /SC $SCHTYPE /MO $EVERY /ST "$ST" /SD "$SD" /TN "$TASKNAME" /TR "$TASCMD" || die "Error calling windows schtasks"
		echo "These are your bKit schedule tasks now"
		schtasks /QUERY|fgrep BKIT
	}
else
	echo "Create a job file in $JOBFILE"
	[[ -n $INSTALL ]] && {
		JOB="${!MINUTE} ${!HOUR} ${!DAYOFMONTH} ${!MONTH} ${!DAYOFWEEK} /bin/bash \"$JOBFILE\""
		{ #add this nJOBE to existing ones
			crontab -l 2>/dev/null
			echo $JOB
		}| sort -u | crontab
		echo "These are your bKit jobs now"
		crontab -l|fgrep BKIT #show all BKIT jobs
	}
fi
echo done
exit 0
#cat "$JOBFILE"


