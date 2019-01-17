#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:$PATH
OS="$(uname -o |tr '[:upper:]' '[:lower:]')"
USER="$(id -nu)"
