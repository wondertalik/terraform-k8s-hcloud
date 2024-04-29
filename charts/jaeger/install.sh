#!/usr/bin/bash
set -eux
NS=observability


if [[ $JAEGER_INSTALL == true ]]
then
  echo "JAEGER_VERSION: $JAEGER_VERSION"
  kubectl get namespace | grep "^$NS" || kubectl create namespace $NS

  #wget https://github.com/jaegertracing/jaeger-operator/releases/download/v1.56.0/jaeger-operator.yaml
  kubectl apply -f charts/jaeger/jaeger-operator.yaml -n observability
fi


