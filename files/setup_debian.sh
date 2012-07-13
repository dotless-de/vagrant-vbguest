#!/bin/bash
function do_install {
	apt-get install -y linux-headers-`uname -r` dkms
}

do_install || (apt-get update && do_install) || exit 1

mount /tmp/VBoxGuestAdditions.iso -o loop /mnt
/mnt/VBoxLinuxAdditions.run --nox11
umount /mnt

exit 0