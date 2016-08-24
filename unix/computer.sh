#!/bin/bash
UUID="$(sudo dmidecode -s system-uuid)"
DOMAIN="$(hostname -d)"
NAME="$(hostname -s)"
