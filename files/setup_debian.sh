#!/bin/bash
apt-get update
apt-get install -y linux-headers-`uname -r` dkms || exit 1
mount /tmp/VBoxGuestAdditions.iso -o loop /mnt
/mnt/VBoxLinuxAdditions.run --nox11
umount /mnt