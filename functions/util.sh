#!/usr/bin/env bash
declare -p jdhflksdghfasdkof >/dev/null 2>&1 && echo module utils apparentely already sourced && return
jdhflksdghfasdkof=1

exists() {
	type "$1" >/dev/null 2>&1;
}

if exists tput
then
	say() {
		tput setaf 1; echo -e "$@">&2; tput sgr0
	}
else
	say() {
		echo -e "$@">&2
	}
fi

msg () {
	for cnt in "${!BASH_SOURCE[@]}"
	do
		[[ "${BASH_SOURCE[$cnt]}" == "${BASH_SOURCE[0]}" ]] || break;	#find first bash_source which is not this file
	done

	say "${BASH_SOURCE[$cnt]}: Line ${BASH_LINENO[$cnt-1]}: $@">&2;		#show error with line number and file name

	for i in $(seq $cnt $(( ${#BASH_SOURCE[@]} - 2 )) )			#show call stach
	do
		say "\tCalled from ${BASH_SOURCE[$i+1]}" "${BASH_LINENO[$i]}">&2
	done
}

die() {
	CODE=$?
	msg "$@"
	exit $CODE;
}

ERROR=0
warn() {
	ERROR=1
	msg "$@"
}

DELTATIME=''
deltatime(){
	let DTIME=$(date +%s -d "$1")-$(date +%s -d "$2")
	SEC=${DTIME}s
	(($DTIME>59)) && {
		let SEC=DTIME%60
		let DTIME=DTIME/60
		SEC=${SEC}s
		MIN=${DTIME}m
		(($DTIME>59)) && {
			let MIN=DTIME%60
			let DTIME=DTIME/60
			MIN=${MIN}m
			HOUR=${DTIME}h
			(($DTIME>23)) && {
				let HOUR=DTIME%24
				let DTIME=DTIME/24
				DAYS=${DTIME}d
			}
		}
	}
	DELTATIME="$DAYS$HOUR$MIN$SEC"
}

sendnotify(){
	local SUBJECT=$1
	local DEST=$2
	local ME=$3
	SMTP="$SDIR/conf/smtp.conf"
	[[ -f $SMTP ]] && source "$SMTP"
	DEST=${EMAIL:-$TO}
	[[ -n $DEST ]] || {
	  warn "Email destination not defined"
	  return 1
	}
	exists email && email -smtp-server $SERVER -subject "$SUBJECT" -from-name "$ME" -from-addr "backup-${ME}@bkit.pt" "$DEST"
	exists mail && mail -s "$SUBJECT" "$DEST"
	echo "Notification sent to $DEST"
}

redirectlogs() {
	local LOGDIR=$(readlink -nm "$1")
	local PREFIX="${2:+$2-}"				#if second argument is set use it immediately follwed by a hyphen as a prefix. Otherwise prefix will be empty
	[[ -d $LOGDIR ]] || mkdir -pv "$LOGDIR" || die "Can't mkdir $LOGDIR" 
	local STARTDATE=$(date +%Y-%m-%dT%H-%M-%S)
	local LOGFILE="$LOGDIR/${PREFIX}log-$STARTDATE"
	local ERRFILE="$LOGDIR/${PREFIX}err-$STARTDATE"
	:> $LOGFILE						#create/truncate log file
	:> $ERRFILE						#creae/truncate err file
	echo "Logs go to $LOGFILE"
	echo "Errors go to $ERRFILE"
	exec 1>"$LOGFILE"					#fork stdout to logfile
	exec 2>"$ERRFILE"					#fork stdin to errfile
}
