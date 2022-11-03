#!/bin/bash
### every exit != 0 fails the script

arch=$(uname -m)
pkgyum=$(command -v yum)
pkgapt=$(command -v apt-get)

if [[ ! -z $pkgyum ]] 2>/dev/null; then
  echo "found yum base"
  yum update -y
  yum install -y openssl jq unzip

  # Hashicorp Products
  if [[ "$arch" == *"x86_64"* ]]; then
    echo "X64 Architecture"
    yum install -y yum-utils
    yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
    yum install -y terraform packer

  elif [[ "$arch" == *"arm"* ]] || [[ "$arch" == *"aarch64"* ]]; then
    echo "ARM Architecture"
    LATESTPK=$(curl -sL https://releases.hashicorp.com/packer/index.json | jq -r '.versions[].builds[].url' | egrep -v 'rc|beta|alpha' | egrep 'linux.*arm64'  | tail -1)
    LATESTTF=$(curl -sL https://releases.hashicorp.com/terraform/index.json | jq -r '.versions[].builds[].url' | egrep -v 'rc|beta|alpha' | egrep 'linux.*arm64'  | tail -1)
    curl $LATESTTF -o /tmp/terraform.zip
    curl $LATESTPK -o /tmp/packer.zip
    unzip -qo /tmp/terraform.zip -d /bin
    unzip -qo /tmp/packer.zip -d /bin
  fi

  # AWS Products
  if [[ "$arch" == *"x86_64"* ]]; then
    echo "X64 Architecture"
    curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip
    unzip -qo /tmp/awscliv2.zip -d /tmp
    /tmp/aws/install

    curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"
    yum install -y session-manager-plugin.rpm

  elif [[ "$arch" == *"arm"* ]] || [[ "$arch" == *"aarch64"* ]]; then
    echo "ARM Architecture"
    curl https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip -o /tmp/awscliv2.zip
    unzip -qo /tmp/awscliv2.zip -d /tmp
    /tmp/aws/install

    curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_arm64/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"
    yum install -y session-manager-plugin.rpm
  fi
fi

if [[ ! -z $pkgapt ]] 2>/dev/null; then
  echo "found apt base"
  apt-get update
  apt-get install -y openssl jq curl unzip lsb-release gnupg

  # Hashicorp Products
  curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --batch --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  if [[ "$arch" == *"x86_64"* ]]; then
      echo "X64 Architecture"
      echo "deb [arch=amd64 signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list
      apt-get -yq update
      apt-get -yq install terraform packer

  elif [[ "$arch" == *"arm"* ]] || [[ "$arch" == *"aarch64"* ]]; then
      echo "ARM Architecture"
      echo "deb [arch=arm64 signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list
      LATEST=$(curl -sL https://releases.hashicorp.com/terraform/index.json | jq -r '.versions[].builds[].url' | egrep -v 'rc|beta|alpha' | egrep 'linux.*arm64'  | tail -1)
      curl $LATEST -o /tmp/terraform.zip
      unzip -qo /tmp/terraform.zip -d /bin
      apt-get -yq update
      apt-get -yq install packer
  fi

  # AWS Products
  if [[ "$arch" == *"x86_64"* ]]; then
      echo "X64 Architecture"
      curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip
      unzip -qo /tmp/awscliv2.zip -d /tmp
      /tmp/aws/install

      curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "/tmp/session-manager-plugin.deb"
      dpkg -i /tmp/session-manager-plugin.deb

  elif [[ "$arch" == *"arm"* ]] || [[ "$arch" == *"aarch64"* ]]; then
      echo "ARM Architecture"
      curl https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip -o /tmp/awscliv2.zip
      unzip -qo /tmp/awscliv2.zip -d /tmp
      /tmp/aws/install

      curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_arm64/session-manager-plugin.deb" -o "/tmp/session-manager-plugin.deb"
      dpkg -i /tmp/session-manager-plugin.deb
  fi
fi

terraform --version
packer --version
aws --version


