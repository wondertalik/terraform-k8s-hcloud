#!/usr/bin/bash
set -eux

#install cilium from charts directory
echo "CILIUM_VERSION: $CILIUM_VERSION"

EXTRA_OPTIONS=""
if [[ $KUBE_PROXY_REPLACEMENT == true ]]; then
  EXTRA_OPTIONS="--set kubeProxyReplacement=true --set k8sServiceHost=$CONTROL_PLANE_ENDPOINT --set k8sServicePort=6443"
else
  EXTRA_OPTIONS="--set knodePort.enabled=true"
fi

# --set ingressController.enabled=true
helm upgrade --install cilium charts/cilium/src/cilium -f charts/cilium/values.yaml \
   --reuse-values \
   --namespace kube-system $EXTRA_OPTIONS \
   --set operator.replicas=$MASTER_COUNT \
   --set hubble.relay.enabled=true \
   --set hubble.ui.enabled=true \
   --set hubble.ui.ingress.enabled=$RELAY_UI_ENABLED \
   --set routingMode=native \
   --set ipv4NativeRoutingCIDR=$POD_NETWORK_CIDR \
   --set ipam.mode=kubernetes \
   --set k8s.requireIPv4PodCIDR=true
kubectl -n kube-system patch ds cilium --type json -p '[{"op":"add","path":"/spec/template/spec/tolerations/-","value":{"key":"node.cloudprovider.kubernetes.io/uninitialized","value":"true","effect":"NoSchedule"}}]'

# install cilium cli tools
ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/v0.16.4/cilium-linux-${ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${ARCH}.tar.gz{,.sha256sum}

#install hubble cli
curl -L --fail --remote-name-all https://github.com/cilium/hubble/releases/download/v0.13.4/hubble-linux-${ARCH}.tar.gz{,.sha256sum}
sha256sum --check hubble-linux-${ARCH}.tar.gz.sha256sum
sudo tar xzvfC hubble-linux-${ARCH}.tar.gz /usr/local/bin
rm hubble-linux-${ARCH}.tar.gz{,.sha256sum}

#Restart unmanaged Pods
kubectl get pods --all-namespaces -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,HOSTNETWORK:.spec.hostNetwork --no-headers=true | grep '<none>' | awk '{print "-n "$1" "$2}' | xargs -L 1 -r kubectl delete pod
kubectl -n kube-system rollout restart deployment/cilium-operator
kubectl -n kube-system rollout restart ds/cilium