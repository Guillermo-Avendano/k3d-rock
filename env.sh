#!/bin/bash

kube_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
[ -d "$kube_dir" ] || {
    echo "FATAL: no current dir (maybe running in zsh?)"
    exit 1
}

host=$(hostname)

################################################################################
# KUBERNETES CONFIG
################################################################################
export KUBE_CLUSTER_NAME="$host-mycluster"                               # cluster/cluster.sh

export KUBECONFIG=$kube_dir/cluster/${KUBE_CLUSTER_NAME}_config.yaml    # cluster/cluster.sh
chmod o-wrx,g-wrx $KUBECONFIG

export KUBE_SOURCE_REGISTRY="registry.rocketsoftware.com"                      # cluster/local_registry.sh
export KUBE_LOCALREGISTRY_NAME="mobius.localhost"                              # cluster/local_registry.sh
export KUBE_LOCALREGISTRY_HOST="localhost"                                     # cluster/local_registry.sh
export KUBE_LOCALREGISTRY_PORT="5000"                                          # cluster/local_registry.sh

export NGINX_EXTERNAL_TLS_PORT=443

export KUBE_PV_ROOT=/home/rocket/pv_cluster

export KUBE_ISTIO_ENABLED="false"
