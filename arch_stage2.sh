#!/bin/bash

# setup automatic ssh auth for root
mkdir -p /root/.ssh
for i in $@ ; do
	curl https://github.com/${i}.keys
done > /root/.ssh/authorized_keys
chmod 0700 /root/.ssh ; chmod 0600 /root/.ssh/authorized_keys

# setup networking and hostname
for i in $(ip link | grep ^[0-9] | awk -F: {'print $2'} | grep -v 'lo'); do
cat << EOF > /etc/systemd/network/${i}.network
[Match]
Name=${i}

[Network]
DHCP=ipv4
EOF
done
echo "What should we call this VM?"
read hostname
hostnamectl set-hostname ${hostname}
echo ${hostname} > /etc/hostname
echo -e "127.0.0.1\t${hostname}" >> /etc/hosts

# set localtime to EST5EDT
ln -sf /usr/share/zoneinfo/EST5EDT /etc/localtime

# start necessary services
for i in sshd systemd-networkd ; do
	systemctl enable ${i}
done

# setup locale
sed -i -e 's~^#en_US~en_US~' /etc/locale.gen
locale-gen

# setup automatic ssh auth for orchard
useradd -m -k /etc/skel orchard
cp -a /root/.ssh ~orchard/.ssh
chown -R orchard:orchard ~orchard/

# setup boot
mkinitcpio -p linux
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
