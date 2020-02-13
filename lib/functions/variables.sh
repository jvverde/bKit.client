#!/usr/bin/env bash
declare -p _0f2cb7c5baf31e857ec0d6ff74d11dbd > /dev/null 2>&1 && echo module variables apparentely already sourced && return
declare -r _0f2cb7c5baf31e857ec0d6ff74d11dbd=1

PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
OS="$(uname -o |tr '[:upper:]' '[:lower:]')"
USER="$(id -nu)"
