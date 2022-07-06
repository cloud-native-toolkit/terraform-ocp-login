#!/usr/bin/env bash

INPUT=$(tee)

BIN_DIR=$(echo "${INPUT}" | grep "bin_dir" | sed -E 's/.*"bin_dir": ?"([^"]*)".*/\1/g')

if [[ -n "${BIN_DIR}" ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi

if ! command -v jq 1> /dev/null 2> /dev/null; then
  echo "jq cli not found" >&2
  echo "bin_dir: ${BIN_DIR}" >&2
  ls -l "${BIN_DIR}" >&2
  exit 1
fi

if ! command -v oc 1> /dev/null 2> /dev/null; then
  echo "oc cli not found" >&2
  echo "bin_dir: ${BIN_DIR}" >&2
  ls -l "${BIN_DIR}" >&2
  exit 1
fi

export KUBECONFIG=$(echo "${INPUT}" | jq -r '.kube_config')
DEFAULT_INGRESS=$(echo "${INPUT}" | jq -r '.default_ingress // empty')


INGRESS=$(oc get ingresses.config/cluster -o json | jq -r --arg DEFAULT "${DEFAULT_INGRESS}" '.spec.domain // $DEFAULT')
VERSION=$(oc version -o json | jq -r '.openshiftVersion // empty')
TLS_SECRET=$(oc get ingresscontroller.operator -n openshift-ingress-operator default -o json | jq -r '.spec.defaultCertificate.name // empty')

jq -n \
  --arg INGRESS "${INGRESS}" \
  --arg VERSION "${VERSION}" \
  --arg TLS_SECRET "${TLS_SECRET}" \
  '{"ingress_subdomain": $INGRESS, "cluster_version": $VERSION, "tls_secret": $TLS_SECRET}'
