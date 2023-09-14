
#!/bin/bash

source "$kube_dir/env.sh"
source "$kube_dir/mobius/env.sh"
source "$kube_dir/cluster/common.sh"

install_keycloak(){

    # Values file from template
    KEYCLOAK_VALUES_TEMPLATE=$kube_dir/mobius/keycloak/templates/values/values-local.yaml
    KEYCLOAK_VALUES=$kube_dir/mobius/keycloak/templates/values-local.yaml
    cp $KEYCLOAK_VALUES_TEMPLATE $KEYCLOAK_VALUES

    replace_tag_in_file $KEYCLOAK_VALUES "<database_user>" $POSTGRESQL_USERNAME;
    replace_tag_in_file $KEYCLOAK_VALUES "<database_password>" $POSTGRESQL_PASSWORD;
    replace_tag_in_file $KEYCLOAK_VALUES "<database_name_keycloak>" $POSTGRESQL_DBNAME_KEYCLOAK;
    replace_tag_in_file $KEYCLOAK_VALUES "<database_host>" $POSTGRESQL_HOST;
    replace_tag_in_file $KEYCLOAK_VALUES "<database_port>" $POSTGRESQL_PORT;
    replace_tag_in_file $KEYCLOAK_VALUES "<KEYCLOAK_URL>" $KEYCLOAK_URL;

 
    if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
       info_message "Creating namespace $NAMESPACE..."
       kubectl create namespace "$NAMESPACE"
    fi
    
    info_message "Deploying Keycloak Helm chart";   
    helm upgrade -f $KEYCLOAK_VALUES $KEYCLOAK_HELM_DEPLOY_NAME $kube_dir/mobius/keycloak/helm/keycloak-16.1.4.tgz --namespace $NAMESPACE --create-namespace --install --wait;

}

get_total_pods() {
  kubectl get pod -n "$NAMESPACE" --no-headers | wc -l | awk '{print $1}'
}

get_running_pods() {
  kubectl get pod -n "$NAMESPACE" --field-selector=status.phase=Running --no-headers | wc -l | awk '{print $1}'
}

wait_for_keycloak_ready() {
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

uninstall_keycloak(){
   if helm list -A | grep $KEYCLOAK_HELM_DEPLOY_NAME > /dev/null 2>&1; then 
      helm uninstall $KEYCLOAK_HELM_DEPLOY_NAME --namespace $NAMESPACE
   fi 

}
