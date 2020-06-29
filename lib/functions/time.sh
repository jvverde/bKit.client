#!/usr/bin/env bash
declare -p _d48fd70a57882a0c40c14af34ac57a8b >/dev/null 2>&1 && return
declare -r _d48fd70a57882a0c40c14af34ac57a8b=1

declare DELTATIME=''
deltatime(){
	let DTIME=$(date +%s -d "$1")-$(date +%s -d "$2")
	declare SEC=${DTIME}s
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
	DELTATIME="${DAYS:-}${HOUR:-}${MIN:-}${SEC:-}"
}
