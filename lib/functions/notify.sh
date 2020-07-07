#!/usr/bin/env bash
declare -p _bkit_notify > /dev/null 2>&1 && [[ ! ${1+$1} =~ ^-f ]] && return

declare _bkit_notify="$(dirname -- "$(readlink -ne -- "${BASH_SOURCE[0]}")")"
source "$_bkit_notify/messages.sh"
source "$_bkit_notify/dirs.sh"
source "$_bkit_notify/exists.sh"

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
	
	exists email && email -smtp-server "$SMTP" -subject "$SUBJECT" -from-name "$ME" -from-addr "backup-${ME}@bkit.pt" "$DEST"
	exists mail && mail -s "$SUBJECT" "$DEST"
	echo "Notification sent to $DEST"
}

${__SOURCED__:+return} #Intended for shellspec tests

if [[ ${BASH_SOURCE[0]} == "$0" ]]
then
  echo "The script '$0' is meant to be sourced"
  echo "Usage: source '$0'"
fi