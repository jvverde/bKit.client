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
