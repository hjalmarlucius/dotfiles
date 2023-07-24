#!/bin/sh
set -e

ZEROTIER_HJARL="172.30.0.0/16"

ufw disable
ufw reset
ufw default deny incoming
ufw default allow outgoing
ufw allow "SSH"
ufw allow "qBittorrent"
ufw allow "syncthing"
ufw allow "WWW Full"

ufw allow in 10000:10100/tcp comment "generic tcp"
ufw allow in 10000:10100/udp comment "generic udp"

# docker
ufw allow in 2376,2377,7946/tcp comment "Docker tcp"
ufw allow in 4789,7946/udp comment "Docker udp"

# media streaming
ufw allow in from 192.168.0.0/16 to any port 8010 proto tcp comment "chromecast"
ufw allow in from 192.168.0.0/16 to any port 4101 proto tcp comment "castnow subs"
ufw allow in from 192.168.0.0/16 to any port 4103 proto tcp comment "castnow transcode"
ufw allow in proto igmp to 224.0.0.0/8 comment "multicast"
# ufw allow in from 192.168.0.0/16 to any port 32768:60999 proto udp comment "ephemeral ports"

# zerotier
ufw allow in 9993/udp comment "zerotier"
ufw allow in from $ZEROTIER_HJARL comment "zerotier hjarl network"

# plex
ufw allow in 1900,7349/udp comment "upnp service discovery"
ufw allow in from 192.168.0.0/16 to any port 32768:61000 proto udp comment "ephemeral ports"

# steam link
ufw allow in 27036,27037/tcp comment "Steam Link tcp"
ufw allow in 27031,27036/udp comment "Steam Link udp"

# enable firewall
ufw enable

# list all firewall rules
ufw status verbose

