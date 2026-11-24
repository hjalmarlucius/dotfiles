# Steps endos.py leaves to you

## oom handling

Add to `sudo systemctl edit user.slice`:
```
[Slice]
OOMScoreAdjust=500
```

## vdirsyncer
- set up with google calendar using
  https://vdirsyncer.pimutils.org/en/stable/config.html#google
- run `vdirsyncer discover` then `vdirsyncer sync`

## firefox
- allow windowed fullscreen by setting full-screen-api.ignore-widgets to
  true in about:config

## coolercontrol
- set coolercontrold log level to WARN: `sudo systemctl edit
  coolercontrold.service`

## k8s
- /etc/hosts: configure
- LUKS unlock over ssh: endos.py installs dracut-crypt-ssh, makes the host key
  and copies crypt-ssh.conf; add the public keys that may unlock
  to /etc/dracut-crypt-ssh/authorized_keys
- /etc/dracut.conf.d/eos-defaults.conf: don't omit network
- /etc/kernel/cmdline: add `rd.neednet=1 ip=dhcp` arguments
- `sudo dracut-rebuild`, then test: reboot, `ssh -p 222 root@<host>`, `unlock`
- in hjarl-system: `uv run -m hosts plan <node>`, then `uv run -m hosts apply <node>`

## docker / home assistant
- docker with non-root daemon
  `sudo groupadd docker && sudo usermod -aG docker $USER`
- run home assistant and music assistant scripts to start docker services

## virtual machine
- /etc/libvirt/network.conf: set `firewall_backend = "iptables"` and restart libvirtd
- download windows + virtio driver ISOs
- vm setup:
  - CPUs: Uncheck "Copy host CPU configuration" and select host-passthrough
  - Disk (IDE/SATA): Change the "Disk bus" to VirtIO
  - NIC (Network): Change "Device model" to virtio
  - Add Hardware: Click "Add Hardware" -> "Storage" -> Select "CDROM" -> select virtio driver iso

## surface (sl3, spro5)
- install the linux-surface kernel and iptsd from the linux-surface repository
  (neither is in Arch or the AUR); the iptsd sleep hook needs them
- remove a hand-installed /lib/systemd/system-sleep/iptsd-hack.sh, or both hooks run

## firewall and beep
- ufw: `sudo ufw allow 22/tcp comment ssh`, `sudo ufw allow 2222`,
  `sudo ufw default allow FORWARD`, ..., `sudo ufw enable`
- `echo "blacklist pcspkr" | sudo tee /etc/modprobe.d/nobeep.conf; sudo rmmod pcspkr`
