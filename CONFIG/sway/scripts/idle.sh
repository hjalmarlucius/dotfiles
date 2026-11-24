#!/bin/bash
# (Re)start swayidle as a user service, so it comes back if it dies.

# With a battery, also tell logind when idle, which then hibernates.
idlehint=()
compgen -G '/sys/class/power_supply/BAT*' >/dev/null && idlehint=(idlehint 300)

systemctl --user stop 'swayidle-*.service' 2>/dev/null
pkill -x swayidle

# KillMode=process: restarting must not kill a running gtklock. A new name each
# time: the old one stays taken while that gtklock runs.
exec systemd-run --user --quiet --collect --unit="swayidle-$$" \
    --property=KillMode=process \
    --property=Restart=always --property=RestartSec=2 \
    --property=StartLimitIntervalSec=60 --property=StartLimitBurst=10 \
    -E WAYLAND_DISPLAY -E SWAYSOCK -E XDG_SESSION_ID \
    swayidle -w \
    timeout 1200 'gtklock -d' \
    timeout 2400 'swaymsg "output * power off"' \
        resume 'swaymsg "output * power on"' \
    "${idlehint[@]}" \
    before-sleep 'gtklock -d' \
    lock 'gtklock -d'
