#!/usr/bin/env bash
declare -p _7233c82197bf04f6ef10f4914614182f >/dev/null 2>&1 && echo module notify apparentely already sourced && return
declare -r _7233c82197bf04f6ef10f4914614182f=1

sendnotify(){
	local SUBJECT=$1
	local DEST=$2
	local ME=$3
	local SMTP="$SDIR/conf/smtp.conf"
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
