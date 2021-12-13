#!/usr/bin/env bash

SERVER="$1"

if [[ -z "${USERNAME}" ]] && [[ -z "${PASSWORD}" ]] && [[ -z "${TOKEN}" ]]; then
  echo "The username and password or the token must be provided to log into ocp"
  exit 1
fi

if [[ -n "${TOKEN}" ]]; then
  AUTH="--token=${TOKEN}"
else
  AUTH="--username=${USERNAME} --password=${PASSWORD}"
fi

echo "Logging in to OCP cluster: ${SERVER}"
oc login --insecure-skip-tls-verify=true ${AUTH} --server="${SERVER}" > /dev/null
