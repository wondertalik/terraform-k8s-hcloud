#!/usr/bin/bash

set -eux

if [[ $KUBE_PROMETHEUS_STACK_INSTALL == true ]]
then
  echo "KUBE_PROMETHEUS_STACK_VERSION: $KUBE_PROMETHEUS_STACK_VERSION"
  helm upgrade --install kube-prometheus-stack charts/kube-prometheus-stack/src/kube-prometheus-stack \
    --set-string grafana.adminPassword=$GRAFANA_ADMIN_PASSWORD \
    -f charts/kube-prometheus-stack/values.yaml --namespace observability --create-namespace
fi