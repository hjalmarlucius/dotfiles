#!/bin/bash

SUSPEND=""
LINES_SHOWN=5
if [[ "$(busctl call org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager CanSuspendThenHibernate)" == 's "yes"' ]]; then
    SUSPEND="󰤄 Suspend\n"
    LINES_SHOWN=6
fi

SELECTION="$(printf "󰌾 Lock\n${SUSPEND}󰍃 Log out\n Reboot\n Reboot to UEFI\n󰐥 Shutdown" | fuzzel --dmenu -a top-right -l $LINES_SHOWN -w 18 -p "Select an option: ")"
[[ -z "$SELECTION" ]] && exit 0

confirm_action() {
    local action="$1"
    CONFIRMATION="$(printf "No\nYes" | fuzzel --dmenu -a top-right -l 2 -w 18 -p "$action?")"
    [[ "$CONFIRMATION" == *"Yes"* ]]
}

case $SELECTION in
*"󰌾 Lock"*)
    gtklock
    ;;
*"󰤄 Suspend"*)
    if confirm_action "Suspend"; then
        systemctl suspend-then-hibernate
    fi
    ;;
*"󰍃 Log out"*)
    if confirm_action "Log out"; then
        swaymsg exit
    fi
    ;;
*" Reboot"*)
    if confirm_action "Reboot"; then
        systemctl reboot
    fi
    ;;
*" Reboot to UEFI"*)
    if confirm_action "Reboot to UEFI"; then
        systemctl reboot --firmware-setup
    fi
    ;;
*"󰐥 Shutdown"*)
    if confirm_action "Shutdown"; then
        systemctl poweroff
    fi
    ;;
esac
