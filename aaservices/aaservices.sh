#!/bin/bash

set -Eeuo pipefail

source "../env.sh"
source "env.sh"
source ../cluster/common.sh
source ../cluster/namespace.sh
source ../cluster/local_registry.sh
source database/database.sh
source "helm/aas.sh"


echo "----------------"
echo "Namespace: $NAMESPACE"
echo "k3d image load aaservices-11.1.2.tar -c $KUBE_CLUSTER_NAME"
echo "----------------"

if [[ $# -eq 0 ]]; then  
  echo "Parameters:"
  echo "==========="
  echo " - imgls     : list images from $KUBE_SOURCE_REGISTRY (var KUBE_IMAGES in env.sh)"
  echo " - imgpull   : pull images from $KUBE_SOURCE_REGISTRY (var KUBE_IMAGES in env.sh)"
  echo " - dbinstall : Install database"
  echo " - dbremove  : Remove database"
  echo " - install   : Install A&A Services"
  echo " - remove    : Remove A&A Services"
  echo " - sleep     : Sleep A&A Services (replicas=0)"
  echo " - wake      : Wake up A&A Services (replicas=normal)"
  echo " - debug     : Generate detail of kubernetes objects in namespace"

else
  for option in "$@"; do

    if [[ $option == "imgpull" ]]; then
         # ../cluster/local_registry.sh
         push_images_to_local_registry; 

    elif [[ $option == "imgls" ]]; then
         # ../cluster/local_registry.sh
         list_images;

    elif [[ $option == "dbinstall" ]]; then

      highlight_message "Deploying database services"
      install_database;
      info_progress_header "Waiting for database services to be ready ...";
      wait_for_database_ready;
      info_message "The database services are ready now.";


    elif [[ $option == "dbremove" ]]; then

      highlight_message "Uninstalling database services"
      uninstall_database;
		 
    elif [[ $option == "install" ]]; then

         if kubectl get namespace "$NAMESPACE" > /dev/null 2>&1; then
             highlight_message "Deploying Audit and Analytics Services";
            install_aaservices;
            info_progress_header "Waiting for Orchestrator services to be ready ...";
            wait_for_aaservices_ready;
            info_message "Audit and Analytics Aervices are ready now.";
          else
            info_message "$NAMESPACE doesn't exist. Excecute './aaservices.sh dbinstall' before."; 
          fi

    elif [[ $option == "remove" ]]; then
         
      highlight_message "Uninstalling Orchestrator services"

      uninstall_aaservices;

    elif [[ $option == "sleep" ]]; then
      if kubectl get namespace "$NAMESPACE" > /dev/null 2>&1; then         
        highlight_message "Orchestrator set replicas to 0"
        kubectl scale deployment aas --replicas=0 -n $NAMESPACE
        kubectl scale statefulset postgresql --replicas=0 -n $NAMESPACE
      fi
    elif [[ $option == "wake" ]]; then
      if kubectl get namespace "$NAMESPACE" > /dev/null 2>&1; then  
        highlight_message "Orchestrator set replicas to normal"
        kubectl scale statefulset postgresql --replicas=1 -n $NAMESPACE
        kubectl scale deployment aas --replicas=1 -n $NAMESPACE
      fi

    elif [[ $option == "debug" ]]; then
      debug_namespace;      
    else    
      echo "($option) is not valid."
    fi
  done
fi
