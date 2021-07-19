#!/usr/bin/env bash
shuf -zer -n10  {A..Z} {a..z} {0..9} |tr -d '\0'
echo
shuf -zer -n20  {A..Z} {a..z} {0..9} |tr -d '\0'
echo
echo -n "$(shuf -zer -n20  {A..Z} {a..z} {0..9} |tr -d '\0')"@bkit.pt
