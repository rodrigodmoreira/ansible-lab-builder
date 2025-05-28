#!/bin/bash

NODES=$(./yq '.[][] | keys() | join(" ")' ${SCRIPT_FOLDER}ansible/inventory.yaml)
echo "ansible managed hosts:"
echo "[ $NODES ]"
for node in $NODES; do
  docker rm -f $node
done
docker rm -f ans

