#!/usr/bin/env bash

BIN_DIR=$(cat .bin_dir)
export KUBECONFIG=$(cat .kubeconfig)

echo "Kube config: ${KUBECONFIG}"

${BIN_DIR}/oc api-resources -o name
