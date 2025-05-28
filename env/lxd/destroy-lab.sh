#!/bin/bash

NODES=$(./yq '.[][] | keys() | join(" ")' ${SCRIPT_FOLDER}ansible/inventory.yaml)
echo "ansible managed hosts:"
echo "[ $NODES ]"
for node in $NODES; do
  lxc delete --force $node
done
lxc delete --force ans

