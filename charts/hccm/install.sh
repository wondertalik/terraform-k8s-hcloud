#!/usr/bin/bash
set -eux

echo "HCCM_VERSION: $HCCM_VERSION"
# #create secrets hcloud in k8s
kubectl -n kube-system delete secret hcloud --ignore-not-found
kubectl -n kube-system create secret generic hcloud --from-literal=token=$K8S_HCLOUD_TOKEN --from-literal=network=$PRIVATE_NETWORK_ID

# #install hcloud-controller-manager
helm upgrade --install hccm charts/hccm/src/hcloud-cloud-controller-manager -f charts/hccm/values.yaml \
    --namespace kube-system \
    --set replicaCount=$MASTER_COUNT \
    --set networking.enabled=true \
    --set networking.clusterCIDR=$POD_NETWORK_CIDR \
    --set nodeSelector."node-role\.kubernetes\.io/control-plane"=