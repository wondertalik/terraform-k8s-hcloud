# Manual charts

## Charts

Update repo

```
helm repo add hcloud https://charts.hetzner.cloud
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add oauth2-proxy https://oauth2-proxy.github.io/manifests
helm repo add datalust https://helm.datalust.co
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update   
``````

### cilium

```
#update cilium chart
helm pull cilium/cilium --untar -d charts/cilium --untardir src
helm show values cilium/cilium > charts/cilium/values.yaml
```

### hccm

```
helm pull hcloud/hcloud-cloud-controller-manager --untar -d charts/hccm --untardir src
helm show values hcloud/hcloud-cloud-controller-manager > charts/hccm/values.yaml
```

### hccm-csi

```
helm pull hcloud/hcloud-csi --untar -d charts/hcloud-csi --untardir src
helm show values hcloud/hcloud-csi > charts/hcloud-csi/values.yaml
```
[]
### cert manager

```
helm pull jetstack/cert-manager --untar -d charts/cert-manager --untardir src
helm show values jetstack/cert-manager > charts/cert-manager/values.yaml
```

### metric server

```
helm pull metrics-server/metrics-server --untar -d charts/metrics-server --untardir src
helm show values metrics-server/metrics-server > charts/metrics-server/values.yaml
```

### ingress-nginx

``` 
helm pull ingress-nginx/ingress-nginx --untar -d charts/ingress-nginx --untardir src
helm show values ingress-nginx/ingress-nginx > charts/ingress-nginx/values.yaml
```

### kube-prometheus-stack

``` 
helm pull prometheus-community/kube-prometheus-stack --untar -d charts/kube-prometheus-stack --untardir src
helm show values prometheus-community/kube-prometheus-stack > charts/kube-prometheus-stack/values.yaml
```

### oauth2-proxy

``` 
helm pull oauth2-proxy/oauth2-proxy --untar -d charts/oauth2-proxy --untardir src
helm show values oauth2-proxy/oauth2-proxy > charts/oauth2-proxy/values.yaml
```

### seq

``` 
helm pull datalust/seq --untar -d charts/seq --untardir src
helm show values datalust/seq > charts/seq/values.yaml
```

### rabbitmq

```
helm pull bitnami/rabbitmq-cluster-operator --untar -d charts/rabbitmq --untardir src
helm show values bitnami/rabbitmq-cluster-operator > charts/rabbitmq/values.yaml
```