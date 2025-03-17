___

# Ansible Laboratory Builder

___

## Overview

This repository contains scripts that automates building a local environment with hosts ready for ansible (control and managed nodes).

In summary:
- Nodes are created based on ansible's inventory yaml file.
- VMs are based on Ubuntu image
- Bootstrap scripts make nodes "ansible ready"
  - Creates an user (ansible) on every node
  - Setup ssh through certificates on each node
  - Setup ansible binaries on control node

Virtualization backends are organized as following:
```text
env
  └<virtualization_backend>
    ├<ansible_folder>   # mounted on ansible control node
    ├<bootstrap_folder> # scripts to setup/enable ansible on nodes
    └<...scripts>       # scripts to handle lab
```

> _Obs: if LXD VMs have no internet inside (cant resolve external hosts),_
> _use script `fix-no-internet.sh` to fix docker related ip table conflicts._
> _Running once at anytime (VMs ON or OFF) should fix it._

___

## Basic setup
1. Run `init-lab.sh` to setup new nodes or recreate over old ones
2. Enter nodes; log in as ansible user; operate ansible
  ```sh
    su ansible
    cd ~/ansible # playbooks and inventory are mounted here
    ansible-playbook playbook.alura.provisioning.yaml \
      -i inventory.yaml \
      -K # prompt for sudo password
  ```

___

## #TODO
    ✅ Finish basic features for lxd
    ⬜️ Update docker env to match lxd setup
    ⬜️ Move ansible projects to external folder
    ⬜️ Add external ansible project selector

