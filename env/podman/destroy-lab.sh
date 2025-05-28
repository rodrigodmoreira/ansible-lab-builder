#!/bin/bash

NODES=$(/tmp/yq '.[][] | keys() | join(" ")' ${SCRIPT_FOLDER}ansible/inventory.yaml)
echo "ansible managed hosts:"
echo "[ $NODES ]"
for node in $NODES; do
  podman rm -f $node
done
podman rm -f ans

