#!/bin/bash

source ../env.sh

terraform destroy -auto-approve

if kubectl get namespace $TF_VAR_NAMESPACE >/dev/null 2>&1; then
  kubectl delete namespace $TF_VAR_NAMESPACE
fi