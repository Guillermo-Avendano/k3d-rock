
 #!/bin/bash

source ../env.sh
source ./env.sh
source ../cluster/common.sh

echo "---------"
echo "Grafana"
echo "-------"

if [[ $# -eq 0 ]]; then  
  echo "Parameters:"
  echo "==========="
  echo " - install : Install Grafana"
  echo " - remove  : Remove Grafana"
 
else
  for option in "$@"; do

    if [[ $option == "install" ]]; then
        info_message "Deploying Grafana Helm chart";
        helm upgrade --create-namespace grafana $kube_dir/tools/grafana/ --namespace $NAMESPACE -f $kube_dir/tools/grafana/values.yaml --install --wait;


    elif [[ $option == "remove" ]]; then
       helm uninstall -n $NAMESPACE grafana

    else    
      echo "($option) is not valid."
    fi
  done  
fi