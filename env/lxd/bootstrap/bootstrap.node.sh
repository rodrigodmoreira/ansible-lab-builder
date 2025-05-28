#!/bin/bash

echo 1 > /tmp/BOOTSTRAP_STARTED

# variables
ANSIBLE_USER=ansible
ANSIBLE_PASSWORD=ansible

# install dependencies
apt update
apt install -y iproute2 openssh-server sudo


# install/enable ssh-server
# unsafe setup. see: https://askubuntu.com/questions/51925/how-do-i-configure-a-new-ubuntu-installation-to-accept-ssh-connections
apt install openssh-server
sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config
sed -i "s/#PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config
mv /etc/ssh/sshd_config.d/60-cloudimg-settings.conf /etc/ssh/sshd_config.d/60-cloudimg-settings.conf.off

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

echo 1 > /tmp/BOOTSTRAP_FINISHED

