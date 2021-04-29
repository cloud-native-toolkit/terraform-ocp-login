#!/usr/bin/env bash

KUBECONFIG=~/.kube/config

oc api-resources -o name
