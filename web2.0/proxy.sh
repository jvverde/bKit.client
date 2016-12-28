#!/bin/bash
[[ -p pipe ]] || mkfifo pipe
[[ -d logs ]] || mkdir logs
nc -lkvp 8088 < pipe |tee -a logs/in.log |nc 10.11.0.135 3000|tee -a logs/out.log > pipe
