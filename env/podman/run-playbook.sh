#!/bin/bash

podman exec -it -u ansible ans bash -c "cd /mnt/ansible && ansible-playbook -i inventory.yaml playbook.alura.provisioning.yaml -K"

