
#!/bin/bash

source "../env.sh"
source "env.sh"
source "$kube_dir/cluster/common.sh"

install_aaservices(){

    # Values file from template
    AAS_VALUES_TEMPLATE=$kube_dir/aaservices/templates/values/values-local.yaml
    AAS_VALUES=$kube_dir/aaservices/helm/values-local.yaml
    cp $AAS_VALUES_TEMPLATE $AAS_VALUES

    DATABASE_URL="jdbc:postgresql://$POSTGRESQL_HOST:$POSTGRESQL_PORT/$POSTGRESQL_DBNAME"

    replace_tag_in_file $AAS_VALUES "<aas_image_name>" $AAS_IMAGE_NAME;
    replace_tag_in_file $AAS_VALUES "<aas_image_version>" $AAS_IMAGE_VERSION;

    replace_tag_in_file $AAS_VALUES "<database_user>" $POSTGRESQL_USERNAME;
    replace_tag_in_file $AAS_VALUES "<database_password>" $POSTGRESQL_PASSWORD;
    replace_tag_in_file $AAS_VALUES "<database_name>" $POSTGRESQL_DBNAME;
    replace_tag_in_file $AAS_VALUES "<database_host>" $POSTGRESQL_HOST;
    replace_tag_in_file $AAS_VALUES "<database_url>" $DATABASE_URL;
    replace_tag_in_file $AAS_VALUES "<aas_license>" $AAS_LICENSE;
    replace_tag_in_file $AAS_VALUES "<aas_pv_enabled>" $AAS_PV_ENABLED
    replace_tag_in_file $AAS_VALUES "<PV_aas_log_vol_claim>" $PV_aas_log_vol_claim; 
    replace_tag_in_file $AAS_VALUES "<PV_aas_shared_claim>" $PV_aas_shared_claim; 

    # AAS Shared folder
    AAS_STORAGE_FILE_TEMPLATE=$kube_dir/aaservices/templates/storage/aas-storage.yaml
    AAS_STORAGE_FILE=$kube_dir/aaservices/templates/aas-storage.yaml
    cp $AAS_STORAGE_FILE_TEMPLATE $AAS_STORAGE_FILE;
    
    replace_tag_in_file $AAS_STORAGE_FILE "<PV_aas_log_vol_claim>" $PV_aas_log_vol_claim; 
    replace_tag_in_file $AAS_STORAGE_FILE "<PV_PATH_aas_log_vol_claim>" $PV_PATH_aas_log_vol_claim;     

    replace_tag_in_file $AAS_STORAGE_FILE "<PV_aas_shared_claim>" $PV_aas_shared_claim; 
    replace_tag_in_file $AAS_STORAGE_FILE "<PV_PATH_aas_shared_claim>" $PV_PATH_aas_shared_claim;   

    # AAS Ingress file from template
    AAS_INGRESS_TEMPLATE=$kube_dir/aaservices/templates/ingress/aas-ingress.yaml
    AAS_INGRESS=$kube_dir/aaservices/templates/aas-ingress.yaml
    cp $AAS_INGRESS_TEMPLATE $AAS_INGRESS

    replace_tag_in_file $AAS_INGRESS "<AAS_URL>" $AAS_URL;
    
    if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
       info_message "Creating namespace $NAMESPACE..."
       kubectl create namespace "$NAMESPACE"
    fi

    info_message "Creating AAS storage";  
    kubectl -n $NAMESPACE apply -f $AAS_STORAGE_FILE 
    
    info_message "Deploying Audit and Analytics Services Helm chart";   
    helm upgrade -f $AAS_VALUES $AAS_HELM_DEPLOY_NAME $kube_dir/aaservices/helm/aas-11.1.2.tgz --namespace $NAMESPACE --create-namespace --install --wait;

    info_message "Creating AAS Ingress"; 
    kubectl -n $NAMESPACE apply -f $AAS_INGRESS
}

get_total_pods() {
  kubectl get pod -n "$NAMESPACE" --no-headers | wc -l | awk '{print $1}'
}

get_running_pods() {
  kubectl get pod -n "$NAMESPACE" --field-selector=status.phase=Running --no-headers | wc -l | awk '{print $1}'
}

wait_for_aaservices_ready() {
  retries=0
  max_retries=60  # Puedes ajustar el número máximo de reintentos según tus necesidades
  
  until [ "$(get_running_pods)" -eq "$(get_total_pods)" ] || [ "$retries" -ge "$max_retries" ]; do
    retries=$((retries+1))
    info_message "Waiting for all pods to be in state 'Running'... (try $retries of $max_retries)"
    sleep 10
  done
  
  if [ "$(get_running_pods)" -eq "$(get_total_pods)" ]; then
    highlight_message "kubectl -n $NAMESPACE get pods"
    kubectl -n $NAMESPACE get pods

    highlight_message "kubectl -n $NAMESPACE get ingress"
    kubectl -n $NAMESPACE get ingress
  else
    echo "Some pods in namespace '$NAMESPACE' are not in state 'Running' after $max_retries attempts."
    exit 1
  fi
}

uninstall_aaservices(){
   if helm list -A | grep $AAS_HELM_DEPLOY_NAME > /dev/null 2>&1; then 
      helm uninstall $AAS_HELM_DEPLOY_NAME --namespace $NAMESPACE
      kubectl -n $NAMESPACE delete pvc/aas-log-vol-claim 
      kubectl -n $NAMESPACE delete pv/aas-log-vol
      kubectl -n $NAMESPACE delete pvc/aas-shared-claim 
      kubectl -n $NAMESPACE delete pv/aas-shared      
   fi 

}
