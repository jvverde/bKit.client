#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
OS=$(uname -o |tr '[:upper:]' '[:lower:]')
SDIR="$(dirname "$(readlink -f "$0")")"                         #Full DIR
