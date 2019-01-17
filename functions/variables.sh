#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
true ${OS:="$(uname -o |tr '[:upper:]' '[:lower:]')"}
true ${SDIR:="$(dirname -- "$(readlink -en -- "$0")")"}                         #Full DIR
true ${USER:="$(id -nu)"}
