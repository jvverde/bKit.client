#!/usr/bin/env bash
declare -p _eb9c465c37f32608ea3f9186c7a74b90 >/dev/null 2>&1 && echo module utils apparentely already sourced && return
declare -r _eb9c465c37f32608ea3f9186c7a74b90=1

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
