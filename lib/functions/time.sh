#!/usr/bin/env bash

declare DELTATIME=''
deltatime(){
	declare -i dtime=$(date +%s -d "$1")-$(date +%s -d "$2")
	declare -i seconds=dtime
	(( seconds > 59 )) && {
		declare -i minutes=seconds/60
		seconds=seconds%60
		(( minutes > 59 )) && {
			declare -i hours=minutes/60
			minutes=minutes%60
			(( hours > 23 )) && {
				declare -i days=hours/24
				hours=hours%24
				(( days > 7 )) && {
					declare -i weeks=days/7
					days=days%7
				}
			}
		}
	}
	DELTATIME="${weeks+${weeks}w}${days+${days}d}${hours+${hours}h}${minutes+${minutes}m}${seconds}s"
}
