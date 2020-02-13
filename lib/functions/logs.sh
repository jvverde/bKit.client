#!/usr/bin/env bash
declare -p _5954d899fd82de856a720d070ab7e05f >/dev/null 2>&1 && return
declare -r _5954d899fd82de856a720d070ab7e05f=1

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
