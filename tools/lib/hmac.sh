#!/usr/bin/env bash
set -u
sdir="$(dirname -- "$(readlink -ne -- "$0")")"

declare -r msg="${1:? "Usage: $0 msg key"}"
declare -r key="${2:? "Usage: $0 msg key"}"

echo -n "$msg"| openssl dgst -sha256 -hmac "$key" -binary | base64