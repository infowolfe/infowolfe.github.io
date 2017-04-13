#!/bin/bash
export GH_USERS="infowolfe angryrancor $1"
cat << EOF
If you'd like to add more github user sshkeys, please append them to
the sh command being run now like:
	curl https://infowolfe.github.io/arch.sh | bash "user1 user2"
hit enter to continue or ^C to interrupt
EOF
read null

do_ssh() {
	# initialize the authorized_keys file
	mkdir -p /root/.ssh/ ; rm /root/.ssh/authorized_keys
	for i in $GH_USERS; do curl -s https://github.com/${i}.keys ; done > /root/.ssh/authorized_keys 
	chmod 0700 /root/.ssh; chmod 0600 /root/.ssh/authorized_keys

	# start sshd
	systemctl start sshd
	
	# symlink python
	ln -s /usr/bin/python2 /usr/bin/python
}

do_disk() {
# fdisk
sectors=$(fdisk -l | awk /sectors/{'print $7'} | head -n1)
disksize=$((sectors / 2 / 1024))
rootsize=$((disksize - 4097))
cat << EOF | fdisk /dev/sda && \ 
o
n
p
1

$((rootsize * 2 * 1024))
a
n
p
2


t
2
82
w

EOF
mkfs.xfs /dev/sda1 && mkswap /dev/sda2 && swapon /dev/sda2 && mount /dev/sda1 /mnt
}

do_install() {
	# insert archlinuxfr repo
cat << EOF >> /etc/pacman.conf
[archlinuxfr]
Server = http://repo.archlinux.fr/\$arch
EOF
	# Setup mirrorlist
	curl -s "https://www.archlinux.org/mirrorlist/?country=US&protocol=http&protocol=https&ip_version=4&ip_version=6&use_mirror_status=on" | sed -e 's~^#S~S~' > /root/allmirrors.txt &&
	rankmirrors -n 6 /root/allmirrors.txt > /etc/pacman.d/mirrorlist
	# install system
	pacstrap /mnt ack base base-devel grub npm open-vm-tools openssh perl python2 rsync rxvt-unicode-terminfo vim yaourt && \
	rsync -ap /etc/pacman.* /mnt/etc/ && \
	curl -s -o /mnt/root/arch_chroot.sh https://infowolfe.github.io/arch_chroot.sh && \
	chmod 755 /mnt/root/arch_chroot.sh && \
	arch-chroot /mnt /root/arch_chroot.sh $GH_USERS
}

do_ssh && do_disk && do_install && reboot
