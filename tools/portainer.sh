
 #!/bin/bash

source ../env.sh
source ./env.sh
source ../cluster/common.sh
source ../cluster/namespace.sh

echo "---------"
echo "Portainer"
echo "---------"

if [[ $# -eq 0 ]]; then  
  echo "Parameters:"
  echo "==========="
  echo " - install : Installs Portainer"
  echo " - remove  : Remove Portainer"
  echo " - debug   : Generate detail of kubernetes objects in namespace"
 
else
  for option in "$@"; do

    if [[ $option == "install" ]]; then
       info_message "Deploying Portainer Helm chart";
       helm upgrade --create-namespace -i -n $NAMESPACE portainer portainer/portainer

    elif [[ $option == "remove" ]]; then
       helm uninstall -n $NAMESPACE portainer

    elif [[ $option == "debug" ]]; then
       debug_namespace; 

    else    
      echo "($option) is not valid."
    fi
  done  
fi