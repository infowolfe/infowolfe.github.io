#!/bin/bash
GH_USERS="infowolfe angryrancor $1"
cat << EOF
If you'd like to add more github user sshkeys, please append them to
the sh command being run now like:
	curl https://infowolfe.github.io/arch.sh | bash "user1 user2"
hit enter to continue or ^C to interrupt
EOF
read

# initialize the authorized_keys file
mkdir -p /root/.ssh/ ; rm /root/.ssh/authorized_keys
for i in $GH_USERS; do curl https://github.com/${i}.keys >> /root/.ssh/authorized_keys ; done
chmod 0700 /root/.ssh; chmod 0600 /root/.ssh/authorized_keys

# start sshd
systemctl start sshd

# symlink python
ln -s /usr/bin/python2 /usr/bin/python

# fdisk
cat << EOF 
Please fdisk with /dev/sda1 as your root and /dev/sda2 as your swap
Your swap space should be approximately equal to your assigned ram
with a minimum of 4GB available.

You will need to use 'n' to create a new partition.
You will need to use 't' on partition 2 with type '82'.
You will need to use 'a' on partition 1 to make it bootable.
EOF
fdisk /dev/sda

mkfs.xfs /dev/sda1
mkswap /dev/sda2
swapon /dev/sda2
mount /dev/sda1 /mnt
pacstrap /mnt base base-devel python2 vim openssh grub

