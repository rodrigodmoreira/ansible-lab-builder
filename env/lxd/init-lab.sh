#!/bin/bash

SCRIPT_FOLDER=$(pwd)/$(dirname $0)/
echo "script folder: $SCRIPT_FOLDER"
cd $SCRIPT_FOLDER

# dependencies: docker yq
if [ -f /tmp/yq ]; then
  echo "skipping yq download"
else
  wget -O /tmp/yq "https://github.com/mikefarah/yq/releases/download/v4.45.1/yq_linux_amd64"
  chmod +x /tmp/yq
fi

# run fix for docker ip table conflict
echo "Running fix-no-internet workaround"
bash $SCRIPT_FOLDER/fix-no-internet.sh

# create nodes
function start_node() {
  CONTAINER_NAME=$1
  BOOTSTRAP_SCRIPT=$2

  echo "Cleaning $CONTAINER_NAME"
  lxc delete --force $CONTAINER_NAME

  echo "Starting $CONTAINER_NAME"

  # create vm
  lxc init --vm ubuntu:24.04 $CONTAINER_NAME
  # mount folders
  lxc config device add $CONTAINER_NAME ansiblevol disk source=$SCRIPT_FOLDER path=/mnt/ansible-lab
  # start vm if stopped
  lxc start $CONTAINER_NAME
  # exec bootstrap
  sleep 10s #TODO: better wait vm availability
  lxc exec $CONTAINER_NAME -T -- bash -c "/mnt/ansible-lab/bootstrap/$BOOTSTRAP_SCRIPT"
}
export -f start_node

# create nodes controlled by ansible
NODES=$(/tmp/yq '.[][] | keys() | join(" ")' ${SCRIPT_FOLDER}ansible/inventory.yaml)
echo "ansible managed hosts:"
echo "[ $NODES ]"
for node in $NODES; do
  echo "- creating $node"
  #TODO: run multiprocess
  start_node $node bootstrap.node.sh 
done


#TODO: make ansible node await for controlled nodes to finish ssh setup
sleep 10s
# nodes_ready=0
# NUM_NODES=$(echo $NODES | wc -w)
# until $(( nodes_ready == $NUM_NODES )); do
#   nodes_ready=0
#   for node in $NODES; do
#     node_ready=$(docker logs $node | grep "> SSH READY" 2>&1 1>/dev/null | echo $?)
#     node_ready=$(( node_ready == 0 ))
#     if $node_ready; then
#       nodes_ready=$(( $nodes_ready + 1))
#     fi
#   done

#   echo "...waiting nodes ssh server ready ($nodes_ready/$NUM_NODES)"
#   sleep 5s
# done


# create ansible master node
echo "ansible host: ans"
echo "- creating ansible node"
start_node ans bootstrap.ansible.sh

