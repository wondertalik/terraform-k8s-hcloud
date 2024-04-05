#!/bin/bash
set -eux

mkdir -p /etc/systemd/system/kubelet.service.d
#for sharedVcpu servers x86_64
NODE_PRIVATE_IP=$(ip -4 -o a show ens10 | awk '{print $4}' | cut -d/ -f1)
if [ -z "$NODE_PRIVATE_IP" ]; then
  #for sharedVcpu servers arm64 (ampere) and dedicated servers
  NODE_PRIVATE_IP=$(ip -4 -o a show enp7s0 | awk '{print $4}' | cut -d/ -f1)
fi

echo "PRE_INIT_NODE_PRIVATE_IP: $NODE_PRIVATE_IP"
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service.d/20-hcloud.conf
[Service]
Environment="KUBELET_EXTRA_ARGS=--cloud-provider=external --node-ip=$NODE_PRIVATE_IP"
EOF