#!/bin/bash

source ../env.sh
source ../common/common.sh

if [ ! -d "cert" ]; then
  mkdir -p "cert"
fi

if ! [ -e "cert/$TF_VAR_MOBIUS_VIEW_URL.key" ] && ! [ -e "cert/$TF_VAR_MOBIUS_VIEW_URL.crt" ]; then

  CERT_NAME=mobius-view-certificate
  HOSTNAME=$TF_VAR_MOBIUS_VIEW_URL
  CERT_FILE=cert//$HOSTNAME.crt
  KEY_FILE=cert/nginx/$HOSTNAME.key

  highlight_message "Generating certificates: cert/$TF_VAR_MOBIUS_VIEW_URL.key and cert/$TF_VAR_MOBIUS_VIEW_URL.crt"

  #openssl req -x509 -newkey rsa:2048 -sha256 -days 3650 -nodes -keyout "cert/$TF_VAR_MOBIUS_VIEW_URL.key" -out "cert/$TF_VAR_MOBIUS_VIEW_URL.crt" -subj "/CN=$TF_VAR_MOBIUS_VIEW_URL/O=$TF_VAR_MOBIUS_VIEW_URL" -addext "subjectAltName=DNS:$TF_VAR_MOBIUS_VIEW_URL" -addext 'extendedKeyUsage=serverAuth,clientAuth'
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${KEY_FILE} -out ${CERT_FILE} -subj "/CN=$HOSTNAME/O=$HOSTNAME" -addext "subjectAltName = DNS:$HOSTNAME";
  base64 -w0 "${hostname}.key" > "base64_${hostname}.key"
  base64 -w0 "${hostname}.crt" > "base64_${hostname}.crt"
fi

if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
   kubectl create namespace "$NAMESPACE";
   kubectl apply -f pvc/mobius-pvc.yaml -n "$NAMESPACE"
   kubectl apply -f pvc/mobiusview-pvc.yaml -n "$NAMESPACE"
fi 

terraform apply -auto-approve

pod_name="view"

pod=$(kubectl -n $TF_VAR_NAMESPACE get pods --output=name | grep "$pod_name")

if kubectl -n $TF_VAR_NAMESPACE get pods --output=name | grep "$pod_name"; then
    kubectl -n $TF_VAR_NAMESPACE delete "$pod"
fi

highlight_message "kubectl -n $TF_VAR_NAMESPACE get pods"
kubectl -n $TF_VAR_NAMESPACE get pods

highlight_message "kubectl -n $TF_VAR_NAMESPACE get ingress"
kubectl -n $TF_VAR_NAMESPACE get ingress


