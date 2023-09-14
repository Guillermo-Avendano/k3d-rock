
 #!/bin/bash

source ../env.sh
source ./env.sh
source ../cluster/common.sh

echo "-------"
echo "pgadmin"
echo "-------"

if [[ $# -eq 0 ]]; then  
  echo "Parameters:"
  echo "==========="
  echo " - install : Install pgadmin"
  echo " - remove  : Remove pgadmin"
 
else
  for option in "$@"; do

    if [[ $option == "install" ]]; then
        info_message "Deploying pgadmin Helm chart";
        helm upgrade --create-namespace pgadmin runix/pgadmin4 --namespace $NAMESPACE -f $kube_dir/tools/pgadmin/values.yaml --install --wait;


    elif [[ $option == "remove" ]]; then
       helm uninstall -n $NAMESPACE pgadmin

    else    
      echo "($option) is not valid."
    fi
  done  
fi