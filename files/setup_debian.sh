#!/bin/bash
mount /tmp/VBoxGuestAdditions.iso -o loop /mnt
. /mnt/VBoxLinuxAdditions.run --nox11
umount /mnt