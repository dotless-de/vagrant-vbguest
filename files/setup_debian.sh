#!/bin/bash
apt-get install -y linux-headers-`uname -r` build-essential dkms
mount /tmp/VBoxGuestAdditions.iso -o loop /mnt
/mnt/VBoxLinuxAdditions.run --nox11
umount /mnt