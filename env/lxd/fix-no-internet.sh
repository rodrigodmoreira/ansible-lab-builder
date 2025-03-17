#!/bin/bash

# run as root
#
# fix internet connection on lxd
# related to docker.io installation
#
# https://discuss.linuxcontainers.org/t/containers-do-not-have-outgoing-internet-access/10844/4

for ipt in iptables iptables-legacy ip6tables ip6tables-legacy; do $ipt --flush; $ipt --flush -t nat; $ipt --delete-chain; $ipt --delete-chain -t nat; $ipt -P FORWARD ACCEPT; $ipt -P INPUT ACCEPT; $ipt -P OUTPUT ACCEPT; done
systemctl reload snap.lxd.daemon

