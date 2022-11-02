#!/bin/bash
### every exit != 0 fails the script
set -e

if [ "${DISTRO}" == "DEBIAN" ] ; then
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  REPO="https://download.docker.com/linux/debian"
fi

if [ "${DISTRO}" == "UBUNTU" ] ; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  REPO="https://download.docker.com/linux/ubuntu"
fi

arch=$(uname -m)
if [ "$arch" == x86_64* ]; then
    echo "X64 Architecture"
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] $REPO $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
    apt-get -yq update
    apt-get -yq install docker-ce docker-ce-cli containerd.io
elif  [ "$arch" == arm* ] || [ "$arch" = aarch64 ]; then
    echo "ARM Architecture"
    echo "deb [arch=arm64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] $REPO $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
    apt-get -yq update
    apt-get -yq install docker-ce docker-ce-cli containerd.io
fi
