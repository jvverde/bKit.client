#!/bin/bash
OS=$(uname -o|tr '[:upper:]' '[:lower:]')
[[ $OS == 'cygwin' ]] && cygstart --action=runas "$@" && exit
type sudo >/dev/null 2>&1 && sudo "$@" && exit
echo "Don't find neither sudo nor cygstart"

