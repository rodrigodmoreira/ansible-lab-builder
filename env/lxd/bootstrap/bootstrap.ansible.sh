#!/bin/bash

echo 1 > /tmp/BOOTSTRAP_STARTED

# variables
ANSIBLE_USER=ansible
ANSIBLE_PASSWORD=ansible

# install dependencies
apt update
apt install -y iproute2 iputils-ping dnsutils sshpass

apt install -y ansible <<EOF
2
134

EOF
  # 2 america
  # 134 sao_paulo


# create ansible user
useradd -m -s /bin/bash $ANSIBLE_USER
usermod -aG sudo $ANSIBLE_USER
passwd $ANSIBLE_USER <<EOF
$ANSIBLE_PASSWORD
$ANSIBLE_PASSWORD

EOF
  # password
  # re-password

su ansible -c "
# fetch dependency yq
wget -O /tmp/yq \"https://github.com/mikefarah/yq/releases/download/v4.45.1/yq_linux_amd64\"
chmod +x /tmp/yq

# get hosts list from ansible inventory
NODES=\$(/tmp/yq '.[][] | keys() | join(\" \")' /mnt/ansible-lab/ansible/inventory.yaml)

# create ssh key
ssh-keygen -q -t ed25519 -f \"/home/$ANSIBLE_USER/.ssh/id_ed25519\" -N \"\"

# for each host
for node in \$NODES; do
  # fetch host signature
  ssh-keyscan -t rsa \$node >> /home/$ANSIBLE_USER/.ssh/known_hosts
  
  # send ssh key to nodes
  sshpass -p \"$ANSIBLE_PASSWORD\" ssh-copy-id $ANSIBLE_USER@\$node

  # disable ssh password login
#  ssh $ANSIBLE_USER@\$node bash -c \"
#    echo 'ChallengeResponseAuthentication no' >> /etc/ssh/sshd_config
#    echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config
#    sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
#    echo 'PermitRootLogin no' >> /etc/ssh/sshd_config
#  \"
done

# setup inventory/playbook
cd /home/$ANSIBLE_USER/
ln -s /mnt/ansible-lab/ansible ansible

# [optional] autoexecute
exit

cd ./ansible
ansible-playbook -i inventory.yaml playbook.yaml
"


echo "Executed bootstrap ansible"

echo 1 > /tmp/BOOTSTRAP_FINISHED

