#!/bin/sh -eux

# create YVA user
useradd -m yva
echo "yva:Default" | chpasswd

# prepare sfdisk script file
cat > /tmp/layout.txt << _EOF_
label: dos
label-id: 0xafd32855
device: /dev/sdb
unit: sectors

/dev/sdb1 : start=        2048, size=     2095104, type=83

_EOF_

fdisk /dev/sdb << _EOF2_
o
I
/tmp/layout.txt
p
w
q
_EOF2_

rm -f /tmp/layout.txt

# creating lvm partitions
pvcreate /dev/sdb1
vgcreate vg02 /dev/sdb1
lvcreate -l 100%VG -n data vg02

# format file system
mkfs.ext4 /dev/vg02/data

# creating mountpoint
mkdir -p /srv/data

#adding fstab entry
echo "/dev/mapper/vg02-data /srv/data               ext4    errors=remount-ro 0       1" >> /etc/fstab

reboot

