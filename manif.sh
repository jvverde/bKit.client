#!/bin/bash
find /cygdrive/? -maxdepth 0 -type d -printf "%f\0" |xargs -0 -I{} find /cygdrive/{} -not -empty -type f -printf "{}|/%P\n" 
