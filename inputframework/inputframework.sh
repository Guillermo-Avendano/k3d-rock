#!/bin/bash

set -Eeuo pipefail

source "../env.sh"
source "env.sh"
source ../cluster/common.sh
source ../cluster/namespace.sh
source ../cluster/local_registry.sh
source "helm/ifw.sh"

echo "----------------"
echo "Namespace: $NAMESPACE"
echo "----------------"

if [[ $# -eq 0 ]]; then  
  echo "Parameters:"
  echo "==========="
  echo " - install   : Install Input Framework"
  echo " - remove    : Remove Input Framework"
  echo " - sleep     : Sleep Input Framework sercvices (replicas=0)"
  echo " - wake      : Wake up Input Framework sercvices (replicas=normal)"
  echo " - debug     : Generate detail of kubernetes objects in namespace"

else
  for option in "$@"; do
		 
    if [[ $option == "install" ]]; then

      highlight_message "Deploying Inputframework Services";
      install_ifw;
      info_progress_header "Waiting for Inputframework services to be ready ...";
      wait_for_ifw_ready;
      info_message "Input Framework services are ready now.";

    elif [[ $option == "remove" ]]; then
         
      highlight_message "Uninstalling Input Framework services"
      uninstall_ifw;

    elif [[ $option == "sleep" ]]; then

      if kubectl get namespace "$NAMESPACE" > /dev/null 2>&1; then         
        highlight_message "Inputframework set replicas to 0"
        kubectl scale deployment inputframework --replicas=0 -n $NAMESPACE
      fi

    elif [[ $option == "wake" ]]; then
    
      if kubectl get namespace "$NAMESPACE" > /dev/null 2>&1; then  
        highlight_message "InputFramework set replicas to normal"
        kubectl scale deployment inputframework --replicas=1 -n $NAMESPACE
      fi

    elif [[ $option == "debug" ]]; then
      debug_namespace;      
    else    
      echo "($option) is not valid."
    fi
  done
fi
