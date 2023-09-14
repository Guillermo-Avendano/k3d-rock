
#!/bin/bash

source "../env.sh"
source "env.sh"
source "$kube_dir/cluster/common.sh"

install_ifw(){

    # Values file from template
    IFW_VALUES_TEMPLATE=$kube_dir/inputframework/templates/values/values-inputframework.yaml
    IFW_VALUES=$kube_dir/inputframework/templates/values-inputframework.yaml
    cp $IFW_VALUES_TEMPLATE $IFW_VALUES

    replace_tag_in_file $IFW_VALUES "<namespace>" $NAMESPACE;
    replace_tag_in_file $IFW_VALUES "<IFW_image_name>" $IFW_IMAGE_NAME;
    replace_tag_in_file $IFW_VALUES "<IFW_image_version>" $IFW_IMAGE_VERSION;

    replace_tag_in_file $IFW_VALUES "<IFW_MOBIUS_REMOTE_HOST_PORT>" $IFW_MOBIUS_REMOTE_HOST_PORT

    replace_tag_in_file $IFW_VALUES "<PV_ifw_volume_claim>" $PV_ifw_volume_claim; 
    replace_tag_in_file $IFW_VALUES "<PV_ifw_inbox_claim>" $PV_ifw_inbox_claim; 

    replace_tag_in_file $IFW_VALUES "<IFW_URL>" $IFW_URL ; 

    # MobiusRemoteCLI
    IFW_MOBIUS_REMOTECLI_JOB_TEMPLATE=$kube_dir/inputframework/templates/job/job_install_MobiusRemoteCLI.yaml
    IFW_MOBIUS_REMOTECLI_JOB=$kube_dir/inputframework/templates/job_install_MobiusRemoteCLI.yaml
    cp $IFW_MOBIUS_REMOTECLI_JOB_TEMPLATE $IFW_MOBIUS_REMOTECLI_JOB

    replace_tag_in_file $IFW_MOBIUS_REMOTECLI_JOB "<IFW_MOBIUS_REMOTE_CLI_URL>" $IFW_MOBIUS_REMOTE_CLI_URL; 
    replace_tag_in_file $IFW_MOBIUS_REMOTECLI_JOB "<IFW_MOBIUS_REMOTE_CLI_SETUP_URL>" $IFW_MOBIUS_REMOTE_CLI_SETUP_URL; 

    # Storage
    if [ "$IFW_PV_LOCAL_ENABLED" == "true" ]; then
        IFW_STORAGE_FILE_TEMPLATE=$kube_dir/inputframework/templates/storage/ifw-storage-local.yaml
    else
        IFW_STORAGE_FILE_TEMPLATE=$kube_dir/inputframework/templates/storage/ifw-storage.yaml
    fi
    
    IFW_STORAGE_FILE=$kube_dir/inputframework/templates/ifw-storage.yaml
    cp $IFW_STORAGE_FILE_TEMPLATE $IFW_STORAGE_FILE;
    
    replace_tag_in_file $IFW_STORAGE_FILE "<PV_ifw_volume_claim>" $PV_ifw_volume_claim; 
    replace_tag_in_file $IFW_STORAGE_FILE "<PV_PATH_ifw_volume_claim>" $PV_PATH_ifw_volume_claim; 

    replace_tag_in_file $IFW_STORAGE_FILE "<PV_ifw_inbox_claim>" $PV_ifw_inbox_claim; 
    replace_tag_in_file $IFW_STORAGE_FILE "<PV_PATH_ifw_inbox_claim>" $PV_PATH_ifw_inbox_claim; 
   
    if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
       info_message "Creating namespace $NAMESPACE..."
       kubectl create namespace "$NAMESPACE"
    fi

    info_message "Creating IFW storage";  
    kubectl -n $NAMESPACE apply -f $IFW_STORAGE_FILE 
    
    info_message "Deploying Input Framework Services Helm chart";   
    helm upgrade -f $IFW_VALUES $IFW_HELM_DEPLOY_NAME $kube_dir/inputframework/helm/inputframework --namespace $NAMESPACE --create-namespace --install --wait;

    info_message "Installing MobiusRemoteCLI..."; 
    kubectl -n $NAMESPACE apply -f $IFW_MOBIUS_REMOTECLI_JOB

}

get_total_pods() {
  kubectl get pod -n "$NAMESPACE" --no-headers | wc -l | awk '{print $1}'
}

get_running_pods() {
  kubectl get pod -n "$NAMESPACE" --field-selector=status.phase=Running --no-headers | wc -l | awk '{print $1}'
}

wait_for_ifw_ready() {
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

uninstall_ifw(){
   if helm list -A | grep $IFW_HELM_DEPLOY_NAME > /dev/null 2>&1; then 
      kubectl -n $NAMESPACE delete job/install-mobius-remote-cli

      highlight_message "Removing Helm Chart $IFW_HELM_DEPLOY_NAME from namespace $NAMESPACE"
      helm uninstall $IFW_HELM_DEPLOY_NAME --namespace $NAMESPACE
  
      kubectl -n $NAMESPACE delete pvc/ifw-volume-claim 
      kubectl -n $NAMESPACE delete pvc/ifw-inbox-claim

      if [ "$IFW_PV_LOCAL_ENABLED" == "true" ]; then
         kubectl -n $NAMESPACE delete pv/ifw-volume     
         kubectl -n $NAMESPACE delete pv/ifw-inbox 
      fi  
      highlight_message "Removing namespace $NAMESPACE"
      kubectl delete ns $NAMESPACE  
   fi 
   
}