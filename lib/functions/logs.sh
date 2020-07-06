#!/usr/bin/env bash
#Defines a functio to redirect stdout and stderr to given dir

redirectlogs() {
	local logdir=$(readlink -nm "$1")
	local prefix="${2:+$2-}"				#if second argument is set use it immediately follwed by a hyphen as a prefix. Otherwise prefix will be empty
	[[ -d $logdir ]] || mkdir -pv "$logdir" || die "Can't mkdir $logdir" 
	local now=$(date +%Y-%m-%dT%H-%M-%S)
	local logfile="$logdir/${prefix}log-$now"
	local errfile="$logdir/${prefix}err-$now"
	:> "$logfile"						#create/truncate log file
	:> "$errfile"						#create/truncate err file
	echo "Logs go to $logfile"
	echo "Errors go to $errfile"
	exec 1>"$logfile"					#fork stdout to logfile
	exec 2>"$errfile"					#fork stderr to errfile
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]
then
  echo "The script '$0' is meant to be sourced"
  echo "Usage: source '$0'"
fi