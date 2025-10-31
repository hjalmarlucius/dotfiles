#!/bin/sh
docker run -d \
    --name homeassistant \
    --privileged \
    --restart=unless-stopped \
    -e TZ=SE \
    -v /home/hjalmarlucius/.config/homeassistant:/config \
    -v /run/dbus:/run/dbus:ro \
    -v /mnt/hdd1/music:/media/music \
    -v /mnt/hdd1/videos:/media/videos \
    --network=host \
    ghcr.io/home-assistant/home-assistant:stable
