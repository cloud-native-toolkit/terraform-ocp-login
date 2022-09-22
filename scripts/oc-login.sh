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

SKIP=$(echo "${INPUT}" | jq -r '.skip')
SERVER=$(echo "${INPUT}" | jq -r '.serverUrl')
USERNAME=$(echo "${INPUT}" | jq -r '.username')
PASSWORD=$(echo "${INPUT}" | jq -r '.password')
TOKEN=$(echo "${INPUT}" | jq -r '.token')
KUBE_CONFIG=$(echo "${INPUT}" | jq -r '.kube_config')
TMP_DIR=$(echo "${INPUT}" | jq -r '.tmp_dir')
CA_CERT=$(echo "${INPUT}" | jq -r '.ca_cert | @base64d')

if [[ "${SKIP}" == "true" ]]; then
  echo "{\"token\": \"${TOKEN}\", \"username\": \"${USERNAME}\", \"password\": \"${PASSWORD}\", \"serverUrl\": \"${SERVER}\", \"skip\": \"${SKIP}\", \"kube_config\": \"${KUBE_CONFIG}\"}"
  exit 0
fi

if [[ -z "${TMP_DIR}" ]]; then
  TMP_DIR="${PWD}/.tmp/cluster"
fi
mkdir -p "${TMP_DIR}"

if [[ -z "${KUBE_CONFIG}" ]]; then
  KUBE_CONFIG="${TMP_DIR}/.kube/config"
fi

if [[ -z "${USERNAME}" ]] && [[ -z "${PASSWORD}" ]] && [[ -z "${TOKEN}" ]]; then
  echo '{"message": "The username and password or the token must be provided to log into ocp"}' >&2
  exit 1
fi

KUBE_DIR=$(dirname "${KUBE_CONFIG}")
mkdir -p "${KUBE_DIR}"
touch "${KUBE_CONFIG}"
chmod 600 "${KUBE_CONFIG}"

CERTIFICATE=""
CERT_FILE=""
if [[ -n "${CA_CERT}" ]]; then
  CERT_FILE="${TMP_DIR}/ca.crt"
  echo "${CA_CERT}" > "${CERT_FILE}"
  CERTIFICATE="--certificate-authority=${CERT_FILE}"
fi

if [[ -n "${TOKEN}" ]]; then
  AUTH_TYPE="token"
  if ! oc login --kubeconfig="${KUBE_CONFIG}" --server="${SERVER}" --insecure-skip-tls-verify=true --token="${TOKEN}" ${CERTIFICATE} 1> /dev/null; then
    echo "Error logging in to ${SERVER} with kubeconfig=${KUBE_CONFIG} and auth=${AUTH_TYPE}" >&2
    oc version >&2
    exit 1
  else
    echo "{\"status\": \"success\", \"message\": \"success\", \"kube_config\": \"${KUBE_CONFIG}\", \"serverUrl\":\"${SERVER}\", \"username\":\"${USERNAME}\", \"password\":\"${PASSWORD}\", \"token\":\"${TOKEN}\"}"
    exit 0
  fi
else
  AUTH_TYPE="username(${USERNAME})"
  if ! oc login --kubeconfig="${KUBE_CONFIG}" --insecure-skip-tls-verify=true --username="${USERNAME}" --password="${PASSWORD}" ${CERTIFICATE} "${SERVER}" 1> /dev/null; then
    echo "Error logging in to ${SERVER} with kubeconfig=${KUBE_CONFIG}, auth=${AUTH_TYPE}, and cert_file=${CERT_FILE}" >&2
    if [[ -n "${CERT_FILE}" ]]; then
      cat "${CERT_FILE}" | wc -c | xargs -I{} echo "cert size: {}" >&2
    fi

    oc login --kubeconfig="${KUBE_CONFIG}" --insecure-skip-tls-verify=true --username="${USERNAME}" --password="${PASSWORD}" ${CERTIFICATE} "${SERVER}" --loglevel=10 >&2
    exit 1
  else
    echo "{\"status\": \"success\", \"message\": \"success\", \"kube_config\": \"${KUBE_CONFIG}\", \"serverUrl\":\"${SERVER}\", \"username\":\"${USERNAME}\", \"password\":\"${PASSWORD}\", \"token\":\"${TOKEN}\"}"
    exit 0
  fi
fi
