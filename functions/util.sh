#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
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
	say "${BASH_SOURCE[1]}: Line ${BASH_LINENO[0]}: $@">&2;
	for i in "${!BASH_LINENO[@]}"
	do
		(( $i == 0 )) && continue
		(( $i == ${#BASH_SOURCE[@]} - 1 )) && break
		say "\tCalled from ${BASH_SOURCE[$i+1]}" "${BASH_LINENO[$i]}">&2
	done
	exit 1;
}

die() {
	msg "$@"
	exit 1;
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
