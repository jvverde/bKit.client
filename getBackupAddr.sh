#!/usr/bin/env bash
SDIR=$(dirname -- "$(readlink -ne -- "$0")")	#Full DIR
source "$SDIR/lib/functions/all.sh"

INITFILE=$ETCDIR/default/conf.init

[[ -e $INITFILE ]] || die "file $INITFILE not found"

grep -Pom 1 '(?<=@).+?(?=:)' "$INITFILE" && exit 0

die 'Server Address not found'
