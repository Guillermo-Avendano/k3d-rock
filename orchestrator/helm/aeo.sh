
#!/bin/bash

source "../env.sh"
source "env.sh"
source "$kube_dir/cluster/common.sh"

install_aeo(){
    AEO_VALUES_TEMPLATE=$kube_dir/orchestrator/helm/template/values.yaml

    AEO_VALUES=$kube_dir/orchestrator/helm/aeo-4.3.1/values.yaml

    cp $AEO_VALUES_TEMPLATE $AEO_VALUES

    IMAGE_SCHEDULER=$KUBE_LOCALREGISTRY_HOST:$KUBE_LOCALREGISTRY_PORT/$IMAGE_SCHEDULER_NAME:$IMAGE_SCHEDULER_VERSION
    IMAGE_CLIENTMGR=$KUBE_LOCALREGISTRY_HOST:$KUBE_LOCALREGISTRY_PORT/$IMAGE_CLIENTMGR_NAME:$IMAGE_CLIENTMGR_VERSION
    IMAGE_AGENT=$KUBE_LOCALREGISTRY_HOST:$KUBE_LOCALREGISTRY_PORT/$IMAGE_AGENT_NAME:$IMAGE_AGENT_VERSION
    DATABASE_URL="jdbc:postgresql://$POSTGRESQL_HOST:$POSTGRESQL_PORT/$POSTGRESQL_DBNAME"

    replace_tag_in_file $AEO_VALUES "<scheduler_image>" $IMAGE_SCHEDULER;
	  replace_tag_in_file $AEO_VALUES "<scheduler_replicas>" $SCHEDULER_REPLICAS;
	
    replace_tag_in_file $AEO_VALUES "<clientmgr_image>" $IMAGE_CLIENTMGR;
    replace_tag_in_file $AEO_VALUES "<clientmgr_replicas>" $CLIENTMGR_REPLICAS;
    replace_tag_in_file $AEO_VALUES "<agent_image>" $IMAGE_AGENT;

    replace_tag_in_file $AEO_VALUES "<database_user>" $POSTGRESQL_USERNAME;
    replace_tag_in_file $AEO_VALUES "<database_passencr>" $POSTGRESQL_PASSENCR;
    replace_tag_in_file $AEO_VALUES "<database_name>" $POSTGRESQL_DBNAME;
    replace_tag_in_file $AEO_VALUES "<database_host>" $POSTGRESQL_HOST;
    replace_tag_in_file $AEO_VALUES "<database_url>" $DATABASE_URL;

    replace_tag_in_file $AEO_VALUES "<aeo_url>" $AEO_URL;

    if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
        kubectl create namespace "$NAMESPACE";
        if [ "$KUBE_ISTIO_ENABLED" == "true" ]; then
            kubectl label namespace $NAMESPACE istio-injection=enabled
        fi  
    fi     

    info_message "Deploying Orchestrator Helm chart";

    helm upgrade -f $AEO_VALUES aeo-$NAMESPACE helm/aeo-4.3.1 --namespace $NAMESPACE --create-namespace --install --wait;
}

update_aeo(){
  # Mientras AEO utilice VOLUMES no mapeados a directorios externos al cluster es igual a install_aeo()
  install_aeo;
}

get_total_pods() {
  kubectl get pod -n "$NAMESPACE" --no-headers | wc -l | awk '{print $1}'
}

get_running_pods() {
  kubectl get pod -n "$NAMESPACE" --field-selector=status.phase=Running --no-headers | wc -l | awk '{print $1}'
}

wait_for_aeo_ready() {
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


uninstall_aeo(){
    helm uninstall aeo-$NAMESPACE --namespace $NAMESPACE
}
