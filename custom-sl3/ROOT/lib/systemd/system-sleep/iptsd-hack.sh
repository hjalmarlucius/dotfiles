#!/bin/sh

# This file (or a link to it) must be in /lib/systemd/system-sleep/iptsd.sh
logger -t "iptsd-hack" "\$0=$0, \$1=$1, \$2=$2"

if [ $1 == "pre" ]; then
  logger -t "iptsd-hack" "stopping iptsd"
  iptsd-systemd -- stop
else
  logger -t "iptsd-hack" "starting iptsd"
  iptsd-systemd -- start
fi
