#!/usr/bin/bash
set -eux

echo "HCCM_CSI_VERSION: $HCCM_CSI_VERSION"

# #install hcloud-controller-manager
helm upgrade --install hcloud-csi charts/hcloud-csi/src/hcloud-csi -n kube-system