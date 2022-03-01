#!/usr/bin/env bash

export KUBECONFIG=$(cat .kubeconfig)

echo "Kube config: ${KUBECONFIG}"

oc api-resources -o name
