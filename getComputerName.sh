#!/bin/bash
SDIR="$(dirname "$(readlink -f "$0")")"				#Full DIR

. "$SDIR/computer.sh"

echo "$DOMAIN.$NAME.$UUID"
