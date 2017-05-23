#!/bin/bash

exists() {
    type "$1" >/dev/null 2>&1;
}

die() {
    echo -e "$@">&2;
    exit 1;
}

ERROR=0
warn() {
    ERROR=1
    echo -e "$@">&2;
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
    local LOGDIR="$1"
    local PREFIX="${2:+$2-}"
    [[ -d $LOGDIR ]] || mkdir -pv "$LOGDIR"
    local STARTDATE=$(date +%Y-%m-%dT%H-%M-%S)
    local LOGFILE="$LOGDIR/${PREFIX}log-$STARTDATE"
    local ERRFILE="$LOGDIR/${PREFIX}err-$STARTDATE"
    :> $LOGFILE
    :> $ERRFILE
    echo "Logs go to $LOGFILE"
    echo "Errors go to $ERRFILE"
    exec 1>"$LOGFILE"
    exec 2>"$ERRFILE"
}
