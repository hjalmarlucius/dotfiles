#!/bin/sh
docker run -d \
    --name musicassistant \
    --privileged \
    --restart=unless-stopped \
    -v /home/hjalmarlucius/.config/musicassistant:/data \
    -v /mnt/hdd1/music/:/media/ \
    --network=host \
    ghcr.io/music-assistant/server
