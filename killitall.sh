#!/bin/bash

kill -9 $(ps -a |fgrep $1 | awk '{print $1}'|grep '[0-9]')
