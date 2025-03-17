#!/bin/bash

# variables
ANSIBLE_USER=ansible
ANSIBLE_PASSWORD=ansible

# install dependencies
apt update
apt install -y iproute2 openssh-server sudo


# install/enable ssh-server
# unsafe setup. see: https://askubuntu.com/questions/51925/how-do-i-configure-a-new-ubuntu-installation-to-accept-ssh-connections
apt install openssh-server
service ssh restart


# create ansible user
useradd -m -s /bin/bash $ANSIBLE_USER
usermod -aG sudo $ANSIBLE_USER
passwd $ANSIBLE_USER <<EOF
$ANSIBLE_PASSWORD
$ANSIBLE_PASSWORD

EOF

echo "> SSH READY"

echo "Executed bootstrap node"

