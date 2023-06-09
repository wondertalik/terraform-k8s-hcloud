#!/usr/bin/bash
set -eux

for i in $(seq $NODE_COUNT)
do
    nodename="${NODE_NAME}-${i}"
    kubectl taint --overwrite=true nodes $nodename "node-role.kubernetes.io/ingress"=:NoSchedule
    kubectl label nodes $nodename "node.kubernetes.io/node-type-app=ingress-controller"
done

echo "INGRESS_VERSION: $INGRESS_VERSION"
helm upgrade --install ingress-nginx charts/ingress-nginx/src/ingress-nginx -f charts/ingress-nginx/values.yaml \
     --namespace ingress-nginx --create-namespace \
     --set controller.tolerations[0].key="node-role.kubernetes.io/ingress",controller.tolerations[0].operator=Exists,controller.tolerations[0].effect=NoSchedule \
     --set controller.nodeSelector."node\.kubernetes\.io/node-type-app"=ingress-controller \
     --set controller.service.annotations."load-balancer\.hetzner\.cloud/name"=$INGRESS_LOAD_BALANCER_NAME \
     --set controller.service.annotations."load-balancer\.hetzner\.cloud/location"=$LOCATION \
     --set controller.service.annotations."load-balancer\.hetzner\.cloud/use-private-ip"=true \
     --set controller.service.annotations."load-balancer\.hetzner\.cloud/type"=$INGRESS_LOAD_BALANCER_TYPE \
     --set controller.replicaCount=$NODE_COUNT \
     --set controller.kind=DaemonSet