#!/usr/bin/env bash
declare -p _6fd3f21f74a871eabe825fcc924bb71e > /dev/null 2>&1 && echo module variables apparentely already sourced && return
declare -r _6fd3f21f74a871eabe825fcc924bb71e=1

PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
OS="$(uname -o |tr '[:upper:]' '[:lower:]')"
true {USER=:"$(id -nu)"}
