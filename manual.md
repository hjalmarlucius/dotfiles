# Steps endos leaves to you

In this order. "All hosts" unless a heading says otherwise. Where a file may hold
other settings already, look before you overwrite it.

## 1. Before endos

```
git clone https://git.hjarl.com/henrik/dotfiles.git ~/dotfiles
cd ~/dotfiles
sudo pacman -S --needed git yay uv
yay -S --needed git-secret
gpg --import <your private key>      # from your own backup
git secret reveal
```
Verify: `git secret list | xargs ls -l` shows each file.

## 2. linux-surface kernel and iptsd (sl3, spro5)

From the linux-surface wiki, Installation and Setup. Check that the fingerprint
shown is `87DE FA4A B94A 99A4 C8C3 1125 56C4 64BA AC42 1453` before signing.
```
curl -s https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc | sudo pacman-key --add -
sudo pacman-key --finger 56C464BAAC421453
sudo pacman-key --lsign-key 56C464BAAC421453
grep -q '^\[linux-surface\]' /etc/pacman.conf || printf '\n[linux-surface]\nServer = https://pkg.surfacelinux.com/arch/\n' | sudo tee -a /etc/pacman.conf
sudo pacman -Syu
sudo pacman -S --needed linux-surface linux-surface-headers iptsd
sudo pacman -S --needed linux-firmware-marvell      # spro5 only: its WiFi
sudo reboot                                         # choose the surface kernel
```
Verify: `uname -r` contains `surface`; `systemctl list-units 'iptsd@*'` lists one.

## 3. endos

```
cd ~/dotfiles
./endos/main.py --dry-run | less
./endos/main.py
```
It asks before it replaces or removes anything, and lists the leftovers of older
versions to choose from. Log out and in again when it has added you to a group.
Verify: `./endos/main.py --dry-run` shows only `ya pkg install`, `virsh net-autostart`
(mothership) and what you said no to; `id -nG` has `docker libvirt` (mothership).

## 4. SSH unlock (mothership, droneship)

endos sets it up; this checks it, and offers repairs one by one. It reads files
with sudo. Nothing is copied to dracut before a key may unlock, and the initramfs
is only rebuilt if you say yes.
```
./endos/main.py --check
```
If it finds no public key to offer, add one (a key of its own is best):
```
sudo install -d -m 755 /etc/dracut-crypt-ssh
sudo install -m 600 /dev/null /etc/dracut-crypt-ssh/authorized_keys   # only if there is none
sudoedit /etc/dracut-crypt-ssh/authorized_keys
```
Note the host key: `ssh-keygen -lf /etc/dracut-crypt-ssh/ssh_host_ed25519_key.pub`.
Verify, when you can reach the console: `sudo reboot`, then from another machine
`ssh -p 222 root@<host>`, check the host key, and run `unlock`.

## 5. Accounts

Calendars and contacts (Google, see the vdirsyncer documentation):
```
vdirsyncer discover
vdirsyncer sync
```
Verify: `systemctl --user list-timers vdirsyncer.timer`; `khal list`; `khard list`.

Firefox: in about:config, set `full-screen-api.ignore-widgets` to `true`.
Verify: a video's fullscreen stays within its window.

## 6. Out of memory: kill the user's programs first

`OOMScoreAdjust` only works in services (systemd ignores it in `user.slice`, where
this step used to put it).
```
sudo install -d /etc/systemd/system/user@.service.d
printf '[Service]\nOOMScoreAdjust=500\n' | sudo tee /etc/systemd/system/user@.service.d/oom.conf
sudo systemctl daemon-reload
```
Verify, after the next login: `systemctl show -p OOMScoreAdjust user@$(id -u)`.

## 7. Beep

```
echo 'blacklist pcspkr' | sudo tee /etc/modprobe.d/nobeep.conf
sudo modprobe -r pcspkr
```
Verify: `lsmod | grep pcspkr` shows nothing.

## 8. Firewall

Allow ssh before enabling it. The k8s hosts also need forwarding and port 2222.
```
sudo ufw allow 22/tcp comment ssh
sudo ufw allow 2222              # mothership, droneship
sudo ufw default allow routed    # mothership, droneship
sudo ufw enable
sudo systemctl enable --now ufw
```
Verify: `sudo ufw status verbose`.

## 9. k8s (mothership, droneship)

- `sudoedit /etc/hosts`: one line per node. Verify: `getent hosts <node>`.
- in the hjarl-system checkout:
  ```
  uv run -m hosts plan <node>
  uv run -m hosts apply <node>
  ```
  Verify: `kubectl get nodes`.
- coolercontrol's log level (endos copies it):
  `sudo systemctl restart coolercontrold`.
  Verify: `systemctl show -p Environment coolercontrold` has `CC_LOG=WARN`.

## 10. Home Assistant and Music Assistant (mothership)

```
~/dotfiles/scripts/run_homeassistant.sh
~/dotfiles/scripts/run_musicassistant.sh
```
Verify: `docker ps` lists both (they restart by themselves from then on).

## 11. Virtual machines (mothership)

```
sudo sed -i.bak 's/^#\?firewall_backend = .*/firewall_backend = "iptables"/' /etc/libvirt/network.conf
sudo systemctl restart libvirtd
```
Verify: `grep ^firewall_backend /etc/libvirt/network.conf`;
`virsh -c qemu:///system net-list` shows `default` active.

For Windows, download its ISO and the virtio driver ISO. In virt-manager:
- CPUs: uncheck "Copy host CPU configuration", select host-passthrough
- Disk: set "Disk bus" to VirtIO
- NIC: set "Device model" to virtio
- Add Hardware > Storage > CDROM: the virtio driver ISO
