#!/usr/bin/env bash
declare -p _aae842b897d8ab9bc8188f6f6c7f512d >/dev/null 2>&1 && return
declare -r _aae842b897d8ab9bc8188f6f6c7f512d=1

exists() {
	type "$1" >/dev/null 2>&1;
}
