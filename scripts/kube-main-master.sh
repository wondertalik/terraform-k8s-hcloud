#!/usr/bin/bash
set -eux

#for sharedVcpu servers x86_64
NODE_PRIVATE_IP=$(ip -4 -o a show ens10 | awk '{print $4}' | cut -d/ -f1)
if [ -z "$NODE_PRIVATE_IP" ]; then
  #for sharedVcpu servers arm64 (ampere) and dedicated servers
  NODE_PRIVATE_IP=$(ip -4 -o a show enp7s0 | awk '{print $4}' | cut -d/ -f1)
fi

echo "KUBE_MAIN_NODE_PRIVATE_IP: $NODE_PRIVATE_IP"
echo "
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
nodeRegistration:
  criSocket: unix:///run/containerd/containerd.sock
localAPIEndpoint:
  advertiseAddress: $NODE_PRIVATE_IP
  bindPort: 6443
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
controlPlaneEndpoint: "$CONTROL_PLANE_ENDPOINT:6443"
networking:
  podSubnet: $POD_NETWORK_CIDR
apiServer:
  certSANs:
    - $NODE_PRIVATE_IP
controllerManager:
  extraArgs:
    bind-address: 0.0.0.0
scheduler:
  extraArgs:
    bind-address: 0.0.0.0
etcd:
  local:
    extraArgs:
      listen-metrics-urls: http://0.0.0.0:2381
clusterName: $CLUSTER_NAME
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
metricsBindAddress: 0.0.0.0:10249
" > /tmp/kubeadm.yml

KUBE_PROXY_REPLACEMENT_OPTIONS=""
if [[ $KUBE_PROXY_REPLACEMENT == true ]]; then
  KUBE_PROXY_REPLACEMENT_OPTIONS="--skip-phases=addon/kube-proxy"
fi

sudo kubeadm init $KUBE_PROXY_REPLACEMENT_OPTIONS \
  --upload-certs \
  --config /tmp/kubeadm.yml \
  --v=5

# used to join nodes to the cluster
sudo mkdir -p /tmp/kubeadm

sudo cp -i /etc/kubernetes/admin.conf /tmp/kubeadm/kubeadm_config
sudo chown -R $SSH_USERNAME:$SSH_USERNAME /tmp/kubeadm/kubeadm_config

sudo systemctl enable kubelet