#!/bin/bash

pacman -Sy
sudo -u orchard yaourt -S gist tmate
cd /root/
wget https://s3.us-east-2.amazonaws.com/orchardos-cmh/linux-surface4/linux-surface4-4.10.15-1-x86_64.pkg.tar.xz
wget https://s3.us-east-2.amazonaws.com/orchardos-cmh/linux-surface4/linux-surface4-docs-4.10.15-1-x86_64.pkg.tar.xz
wget https://s3.us-east-2.amazonaws.com/orchardos-cmh/linux-surface4/linux-surface4-headers-4.10.15-1-x86_64.pkg.tar.xz
pacman -U linux-surface4*.pkg.*
