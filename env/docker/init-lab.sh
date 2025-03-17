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

# create docker network to resolve container names as dns
if $(docker network list | grep lab-net 2>&1 1>/dev/null); then
  echo "skipping network creation"
else
  docker network create --driver bridge lab-net
fi

# create nodes
function start_node() {
  CONTAINER_NAME=$1
  BOOTSTRAP_SCRIPT=$2

  echo "Cleaning $CONTAINER_NAME"
  docker rm -f $CONTAINER_NAME

  echo "Starting $CONTAINER_NAME"
  docker run \
    --name $CONTAINER_NAME \
    --privileged \
    --detach \
    --expose 22 \
    --network lab-net \
    --volume ${SCRIPT_FOLDER}bootstrap/$BOOTSTRAP_SCRIPT:/mnt/bootstrap.sh \
    --volume ${SCRIPT_FOLDER}ansible/:/mnt/ansible/ \
    --entrypoint /bin/bash \
    ubuntu \
    -c "cp /mnt/bootstrap.sh /root/bootstrap.sh && chmod +x /root/bootstrap.sh && /root/bootstrap.sh && tail -f /dev/null"
}

# create nodes controlled by ansible
NODES=$(/tmp/yq '.[][] | keys() | join(" ")' ${SCRIPT_FOLDER}ansible/inventory.yaml)
echo "ansible managed hosts:"
echo "[ $NODES ]"
for node in $NODES; do
  echo "- creating $node"
  start_node $node bootstrap.node.sh
done


sleep 10s
#TODO: make ansible node await for controlled nodes to finish ssh setup
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

