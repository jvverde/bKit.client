#!/usr/bin/env bash
#Common Code
RSYNCOPTIONS=()
USER="$(id -nu)"
CONFIGDIR="$(readlink -ne -- "$SDIR/conf/$USER/default" || find "$SDIR/conf/$USER" -type d -exec test -e "{}/conf.init" ';' -print -quit)"
CONFIG="$CONFIGDIR/conf.init"
[[ -e $CONFIG ]] && source "$CONFIG"

export RSYNC_PASSWORD="$(<${PASSFILE})" || die "Pass file not found on location '$PASSFILE'"
[[ -n $SSH ]] && export RSYNC_CONNECT_PROG="$SSH"

SDIR="$(dirname -- "$(readlink -en -- "$0")")"       #Full DIR

exists() { type "$1" >/dev/null 2>&1;}
die() { echo -e "$@" >&2; exit 1;}
warn() { echo -e "$@" >&2;}

