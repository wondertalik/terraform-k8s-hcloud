#!/usr/bin/bash
set -eux

# used to join nodes to the cluster
sudo mkdir -p /tmp/kubeadm
sudo chown -R $SSH_USERNAME:$SSH_USERNAME /tmp/kubeadm
sudo kubeadm token create --print-join-command > /tmp/kubeadm/kubeadm_join

sudo kubeadm init phase upload-certs --upload-certs > /tmp/cert.key
export CERT_KEY="$(tail -1 /tmp/cert.key)"
sudo kubeadm token create --print-join-command --certificate-key $CERT_KEY > /tmp/kubeadm/kubeadm_control_plane_join