#!/bin/bash

set -Eeuo pipefail

source "../env.sh"
source "env.sh"
source ../cluster/common.sh
source ../cluster/local_registry.sh
source database/database.sh
source "helm/aeo.sh"


echo "----------------"
echo "Namespace: $NAMESPACE"
echo "----------------"

if [[ $# -eq 0 ]]; then  
  echo "Parameters:"
  echo "==========="
  echo " - imgls     : List images from $KUBE_SOURCE_REGISTRY (var KUBE_IMAGES in env.sh)"
  echo " - imgpull   : Pull images from $KUBE_SOURCE_REGISTRY (var KUBE_IMAGES in env.sh)"
  echo " - dbinstall : Install database"
  echo " - dbremove  : Remove database"
  echo " - install   : Install Enterprise Orchestrator"
  echo " - update    : Update Enterprise Orchestrator"
  echo " - remove    : Remore Enterprise Orchestrator"
  echo " - sleep     : Sleep Enterprise Orchestrator (replicas=0)"
  echo " - wake      : Wake up Enterprise Orchestrator (replicas=normal)"
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

      highlight_message "Deploying Orchestrator services";
      install_aeo;
      info_progress_header "Waiting for Orchestrator services to be ready ...";
      wait_for_aeo_ready;
      info_message "Orchestrator services are ready now.";

    elif [[ $option == "update" ]]; then

      highlight_message "Updating Orchestrator services";
      update_aeo;
      info_progress_header "Waiting for Orchestrator services to be ready ...";
      wait_for_aeo_ready;
      info_message "Orchestrator services are ready now.";

    elif [[ $option == "remove" ]]; then
         
      highlight_message "Uninstalling Orchestrator services"

      uninstall_aeo;

    elif [[ $option == "sleep" ]]; then
         
      highlight_message "Orchestrator set replicas to 0"
      kubectl scale deployment aeo-clientmgr --replicas=0 -n $NAMESPACE
      kubectl scale deployment aeo-agent --replicas=0 -n $NAMESPACE
      kubectl scale deployment aeo-scheduler --replicas=0 -n $NAMESPACE
      kubectl scale statefulset postgresql --replicas=0 -n $NAMESPACE

    elif [[ $option == "wake" ]]; then
         
      highlight_message "Orchestrator set replicas to normal"
      kubectl scale statefulset postgresql --replicas=1 -n $NAMESPACE
      kubectl scale deployment aeo-scheduler --replicas=2 -n $NAMESPACE
      kubectl scale deployment aeo-agent --replicas=1 -n $NAMESPACE
      kubectl scale deployment aeo-clientmgr --replicas=1 -n $NAMESPACE

    elif [[ $option == "debug" ]]; then
      debug_namespace;      
    else    
      echo "($option) is not valid."
    fi
  done
fi
