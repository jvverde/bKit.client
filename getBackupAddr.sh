#!/usr/bin/env bash
SDIR=$(dirname "$(readlink -f "$0")")	#Full DIR

die() { echo -e "$@">&2; exit 1; }

INITFILE=$SDIR/conf/conf.init

[[ -e $INITFILE ]] || die "file $INITFILE not found"

grep -Pom 1 '(?<=@).+?(?=:)' "$INITFILE" && exit 0

die 'Server Address not found'
