#!/usr/bin/env bash

INPUT=$(tee)

SERVER=$(echo "${INPUT}" | grep "serverUrl" | sed -E 's/.*"serverUrl": ?"([^"]*)".*/\1/g')
USERNAME=$(echo "${INPUT}" | grep "username" | sed -E 's/.*"username": ?"([^"]*)".*/\1/g')
PASSWORD=$(echo "${INPUT}" | grep "password" | sed -E 's/.*"password": ?"([^"]*)".*/\1/g')
TOKEN=$(echo "${INPUT}" | grep "token" | sed -E 's/.*"token": ?"([^"]*)".*/\1/g')
KUBE_CONFIG=$(echo "${INPUT}" | grep "kube_config" | sed -E 's/.*"kube_config": ?"([^"]*)".*/\1/g')
TMP_DIR=$(echo "${INPUT}" | grep "tmp_dir" | sed -E 's/.*"tmp_dir": ?"([^"]*)".*/\1/g')

if [[ -z "${TMP_DIR}" ]]; then
  TMP_DIR="${PWD}/.tmp/cluster"
fi
mkdir -p "${TMP_DIR}"

if [[ -z "${KUBE_CONFIG}" ]]; then
  KUBE_CONFIG="${TMP_DIR}/.kube/config"
fi

if [[ -z "${USERNAME}" ]] && [[ -z "${PASSWORD}" ]] && [[ -z "${TOKEN}" ]]; then
  echo '{"message": "The username and password or the token must be provided to log into ocp"}'
  exit 1
fi

if [[ -n "${TOKEN}" ]]; then
  AUTH="--token=${TOKEN}"
else
  AUTH="--username=${USERNAME} --password=${PASSWORD}"
fi

if oc login --insecure-skip-tls-verify=true ${AUTH} --server="${SERVER}" 1> /dev/null 2> "${TMP_DIR}/error.log"; then
  echo "{\"status\": \"success\", \"message\": \"success\" \"kube_config\": \"${KUBE_CONFIG}\"}"
  exit 0
else
  echo "{\"status\": \"error\", \"message\": \"$(cat ${TMP_DIR}/error.log)\"}"
  exit 1
fi
