#!/usr/bin/env bash
set -u
sdir="$(dirname -- "$(readlink -ne -- "$0")")"

declare schema='https'
declare dport=8766

[[ $1 =~ ^-i$ ]] && {
  schema='http'
  dport=8765
  shift
}

declare -r user="${1:? "Usage: $0 username server"}"
declare -r server="${2:? "Usage: $0 username server"}"
declare -r port="${3:-$dport}"

curl -s --cacert "$sdir"/../certs/bkitCA.crt -X GET "$schema://$server:$port/v1/auth/check/$user" |jq .
echo