#!/usr/bin/bash
set -eux

if [[ $RABBITMQ_INSTALL == true ]]
then
  echo "RABBITMQ_VERSION: $RABBITMQ_VERSION"
  helm upgrade --install rabbitmq charts/rabbitmq/src/rabbitmq-cluster-operator -f charts/rabbitmq/values.yaml \
    --set clusterOperator.watchAllNamespaces=false \
    --set clusterOperator.watchNamespaces[0]="rabbitmq-cluster" \
    --namespace rabbitmq-cluster --create-namespace
fi
