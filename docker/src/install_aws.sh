#!/bin/bash
### every exit != 0 fails the script
set -e

arch=$(uname -m)
if [ "$arch" == x86_64* ]; then
    echo "X64 Architecture"
    curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip
    unzip -q /tmp/awscliv2.zip -d /tmp
    /tmp/aws/install

    curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "/tmp/session-manager-plugin.deb"
    dpkg -i /tmp/session-manager-plugin.deb

elif [ "$arch" == arm* ] || [ $arch = aarch64 ]; then
    echo "ARM Architecture"
    curl https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip -o /tmp/awscliv2.zip
    unzip -q /tmp/awscliv2.zip -d /tmp
    /tmp/aws/install

    curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_arm64/session-manager-plugin.deb" -o "/tmp/session-manager-plugin.deb"
    dpkg -i /tmp/session-manager-plugin.deb
fi