#!/usr/bin/env bash
set -u
sdir="$(dirname -- "$(readlink -ne -- "$0")")"

declare schema='https'
declare dport=8766

[[ ${1+$1} =~ ^-i$ ]] && {
  schema='http'
  dport=8765
  shift
}
declare usage="Usage: $0 username email server"
declare -r username="${1:? $usage}"
declare -r email="${2:? $usage}"
declare -r server="${3:? $usage}"
declare -r port="${4:-$dport}"

jq -n --arg username $username --arg email $email '{"username":$username, "email":$email}' |
  curl -s --cacert "$sdir"/../certs/bkitCA.crt -X POST "$schema://$server:$port/v1/auth/request" -H "Content-Type: application/json" -d @-|jq .
echo