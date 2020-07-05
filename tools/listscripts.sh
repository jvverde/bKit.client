#!/usr/bin/env bash
#get a list of scripts and update package.json
die() {
  echo -e "$@"
  exit 1
}

declare -r sdir=$(dirname -- "$(readlink -ne -- "$0")")	#Full SDIR
declare -r src="${1:-"${sdir%/tools*}"}"  #If not specified, assuming we are inside a tools directory under client area
declare -r package="$src/package.json"

[[ -e $package ]] || die "'$package' not found"

declare -r scripts="[$(find "$src" -maxdepth 1 -type f -name '*.sh' -printf "\"%f\","| sed 's/,$/\n/')]"
sed -i."old@$(date)" -E "s/(.+scripts.+:)(.+?)/\1 $scripts,/" "$package"