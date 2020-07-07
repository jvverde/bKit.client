#!/usr/bin/env bash
#get a list of scripts and update package.json
die() {
  echo -e "$@"
  exit 1
}

declare -r sdir=$(dirname -- "$(readlink -ne -- "$0")")	#Full SDIR
declare -r src="${1:-"$sdir/.."}"  #If not specified, assuming we are inside a tools directory under client area
declare -r package="$src/package.json"

[[ -e $package ]] || die "'$package' not found"

declare -r scripts="[$(find "$src" -maxdepth 1 -type f \( -name '*.sh' -o -name '*.bat' \) -printf "\"%f\",\n"| sed '${s/,$//g}')]"
declare -r files="[$(find "$src" -mindepth 2 -type f ! -path '**/.**' -printf "\"%P\",\n"| sed '${s/,$//g}')]"
declare -r old="${package}.old@$(date)"
cp "$package" "$old"
jq \
  --argjson scripts "$(echo $scripts| jq '.')" \
  --argjson files "$(echo $files| jq '.')" \
  '. | .scripts |= $scripts | .files |= $files' "$old" > "$package" 
#sed -i."old@$(date)" -E "s/(.+scripts.+:)(.+?)/\1 $scripts,/" "$package"
#sed -E "s/(.+scripts.+:)(.+?)/\1 $scripts,/" "$package"