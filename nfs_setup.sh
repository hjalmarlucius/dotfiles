#!/bin/bash
LOC=$1
echo "/srv/nfs/state    *.hjarl.com(rw,async,no_subtree_check,no_root_squash)    10.0.0.0/16(rw,async,no_subtree_check,no_root_squash)" | sudo bash -c "cat >> /etc/exports"
sudo hostnamectl set-hostname ${LOC}
sudo apt install nfs-kernel-server
sudo systemctl enable --now nfs-kernel-server
sudo mkdir -p /srv/nfs/state
sudo chown -R 1000:1000 /srv/nfs/state
sudo ln -s /srv/nfs/state/ /mnt/${LOC}
sudo chown -R 1000:1000 /mnt/${LOC}
sudo exportfs -a
