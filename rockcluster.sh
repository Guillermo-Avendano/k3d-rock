#!/bin/bash

source "./env.sh"

source "$kube_dir/cluster/cluster.sh"
source "$kube_dir/cluster/kubernetes.sh"

echo "----------------"
echo "Current Cluster: $KUBE_CLUSTER_NAME"
echo "----------------"

if [[ $# -eq 0 ]]; then  
  echo "Parameters:"
  echo "==========="
  echo " - start   : start $PRODUCT cluster"
  echo " - stop    : stop $PRODUCT cluster"
  echo " - list    : list clusters"
  echo " - create  : create $PRODUCT cluster"  
  echo " - remove  : remove $PRODUCT cluster"
 
else
  for option in "$@"; do
    if [[ $option == "start" ]]; then

         if ! exist_cluster; then
            echo "$KUBE_CLUSTER_NAME cluster doesn't exist"
         elif isactive_cluster; then
            echo "$KUBE_CLUSTER_NAME cluster is active"
         else
            # cluster/cluster.sh
            start_cluster;
         fi

    elif [[ $option == "stop" ]]; then

         if isactive_cluster; then
            # cluster/cluster.sh
            stop_cluster;
         else
            echo "$KUBE_CLUSTER_NAME cluster is not active"
         fi
		 
    elif [[ $option == "list" ]]; then
         # cluster/cluster.sh
         list_cluster;

    elif [[ $option == "create" ]]; then
         
         if isactive_cluster; then
            echo "$KUBE_CLUSTER_NAME cluster is active"
         else    
            # cluster/cluster.sh
            create_cluster;
         fi

    elif [[ $option == "remove" ]]; then
         
         registry_name=k3d-$KUBE_LOCALREGISTRY_NAME

         if exist_cluster; then
            # cluster/cluster.sh
            remove_cluster;
         else
            echo "$KUBE_CLUSTER_NAME cluster doesn't exist" 
            if k3d registry list | grep $registry_name >/dev/null; then
               echo "Deleting existing registry $registry_name"
               k3d registry delete $registry_name
            fi   
         fi

    else    
      echo "($option) is not valid."
    fi
  done
fi
