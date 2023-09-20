
 #!/bin/bash

source ../env.sh
source ./env.sh
source ../cluster/common.sh
source ../cluster/namespace.sh

echo "---------"
echo "Grafana"
echo "-------"

if [[ $# -eq 0 ]]; then  
  echo "Parameters:"
  echo "==========="
  echo " - install : Install Grafana"
  echo " - remove  : Remove Grafana"
  echo " - debug   : Generate detail of kubernetes objects in namespace"  
 
else
  for option in "$@"; do

    if [[ $option == "install" ]]; then
        info_message "Deploying Grafana Helm chart";
        helm upgrade --create-namespace grafana $kube_dir/tools/grafana/ --namespace $NAMESPACE -f $kube_dir/tools/grafana/values.yaml --install --wait;


    elif [[ $option == "remove" ]]; then
       helm uninstall -n $NAMESPACE grafana

    elif [[ $option == "debug" ]]; then
       debug_namespace; 
       
    else    
      echo "($option) is not valid."
    fi
  done  
fi