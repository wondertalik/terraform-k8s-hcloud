#!/usr/bin/bash
set -eux

#add taint for asset node
for node in $(kubectl get nodes -o custom-columns=NAME:.metadata.name | grep asset)
do
  kubectl taint --overwrite nodes $node node-role.kubernetes.io/only-assets:NoSchedule
  kubectl label nodes $node node-restriction.kubernetes.io/only-assets=true
done