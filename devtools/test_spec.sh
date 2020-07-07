#!/usr/bin/env bash
find spec -iname '*_spec.sh' -exec shellspec --color --shell bash ${1+"$@"} "{}" '+'