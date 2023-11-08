#!/bin/bash

kube_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
[ -d "$kube_dir" ] || {
    echo "FATAL: no current dir (maybe running in zsh?)"
    exit 1
}

for var in "${!IFW_@}"; do
    unset "$var"
done

for var in "${!MOBIUS_@}"; do
    unset "$var"
done

for var in "${!IMAGE_@}"; do
    unset "$var"
done

for var in "${!AAS_@}"; do
    unset "$var"
done

file_env=$kube_dir/.env  

# Verify if the file
if [ -e "$file_env" ]; then

  file_env_filter=$(grep -vE '^\s*$|^\s*#' "$file_env")
  file_env_clean=$(echo "$file_env_filter" | sed 's/[[:space:]]*$//')

  # Iterate line by line
  while IFS= read -r line_env; do
    #echo $line_env
    export $line_env  
  done <<< $file_env_clean
else
  echo "File $file_env do not exist."
fi

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

export KUBE_PV_ROOT=$kube_dir/pv_cluster
export KUBE_PV_ROOT_MAP_ALL=true

export KUBE_ISTIO_ENABLED="false"

export KUBE_NFS_ENABLED=${KUBE_NFS_ENABLED:-false}

export KUBE_STORAGE_CLASS=local-path
export KUBE_STORAGE_READ_WRITE=ReadWriteOnce



################################################################################
# PERSISTENT VOLUMES
################################################################################
export MOBIUS_PV_STORAGE=${MOBIUS_PV_STORAGE:-$KUBE_PV_ROOT/mobius-storage}
export MOBIUS_PV_DIAGNOSE=${MOBIUS_PV_DIAGNOSE:-$KUBE_PV_ROOT/mobius-diagnose}

export MOBIUSVIEW_PV_PRESENTATION=${MOBIUSVIEW_PV_PRESENTATION:-$KUBE_PV_ROOT/mobiusview-presentation}
export MOBIUSVIEW_PV_DIAGNOSE=${MOBIUSVIEW_PV_DIAGNOSE:-$KUBE_PV_ROOT/mobiusview-diagnose}

export IFW_PV_VOLUME=${IFW_PV_VOLUME:-$KUBE_PV_ROOT/ifw-volume}
export IFW_PV_INBOX=${IFW_PV_INBOX:-$KUBE_PV_ROOT/ifw-inbox}

export AAS_PV_LOG=${AAS_PV_LOG:-$KUBE_PV_ROOT/aas-log}
export AAS_PV_SHARED=${AAS_PV_SHARED:-$KUBE_PV_ROOT/aas-shared}