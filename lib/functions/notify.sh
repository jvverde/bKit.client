#!/usr/bin/env bash
declare -p _3dcc753aa5d6ffb1b182f347a0727075 >/dev/null 2>&1 && return
declare -r _3dcc753aa5d6ffb1b182f347a0727075=1

sendnotify(){
	local SUBJECT=$1
	local ME=$2
	local DEST=$3
	local confile="$ETCDIR/smtp/conf.init"

	[[ -f $confile ]] || {
		warn "The config file '$confile' doesn't exists"
		return 1
	}
	
	source "$confile"

	DEST="${DEST:-$TO}"

	[[ -n $DEST ]] || {
	  warn "Email destination not defined"
	  return 1
	}
	
	exists email && email -smtp-server $SMTP -subject "$SUBJECT" -from-name "$ME" -from-addr "backup-${ME}@bkit.pt" "$DEST"
	exists mail && mail -s "$SUBJECT" "$DEST"
	echo "Notification sent to $DEST"
}
