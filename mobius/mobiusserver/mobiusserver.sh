#!/bin/bash
set -Eeuo pipefail

source ../env.sh
source ./env.sh
source ../cluster/common.sh


install_mobius() {
	
	MOBIUS_STORAGE_FILE=mobius_storage.yaml;
    cp $kube_dir/mobius/mobiusserver/storage/local/templates/$MOBIUS_STORAGE_FILE $kube_dir/mobius/mobiusserver/$MOBIUS_STORAGE_FILE;
	
	replace_tag_in_file $kube_dir/mobius/mobiusserver/$MOBIUS_STORAGE_FILE "<PV_PATH_mobius_storage_claim>" $PV_PATH_mobius_storage_claim;
	replace_tag_in_file $kube_dir/mobius/mobiusserver/$MOBIUS_STORAGE_FILE "<PV_PATH_mobius_diagnose_claim>" $PV_PATH_mobius_diagnose_claim;
	
	MOBIUS_VALUES_FILE=mobiusserver.yaml;
    cp $kube_dir/mobius/mobiusserver/templates/$MOBIUS_VALUES_FILE $kube_dir/mobius/mobiusserver/$MOBIUS_VALUES_FILE;
	replace_tag_in_file $kube_dir/mobius/mobiusserver/$MOBIUS_VALUES_FILE "<KUBE_LOCALREGISTRY_HOST>" $KUBE_LOCALREGISTRY_HOST;
	replace_tag_in_file $kube_dir/mobius/mobiusserver/$MOBIUS_VALUES_FILE "<KUBE_LOCALREGISTRY_PORT>" $KUBE_LOCALREGISTRY_PORT;
	replace_tag_in_file $kube_dir/mobius/mobiusserver/$MOBIUS_VALUES_FILE "<IMAGE_NAME_MOBIUS>" $IMAGE_NAME_MOBIUS;
	replace_tag_in_file $kube_dir/mobius/mobiusserver/$MOBIUS_VALUES_FILE "<IMAGE_VERSION_MOBIUS>" $IMAGE_VERSION_MOBIUS;
	replace_tag_in_file $kube_dir/mobius/mobiusserver/$MOBIUS_VALUES_FILE "<POSTGRESQL_USERNAME>" $POSTGRESQL_USERNAME;
	replace_tag_in_file $kube_dir/mobius/mobiusserver/$MOBIUS_VALUES_FILE "<POSTGRESQL_PASSWORD>" $POSTGRESQL_PASSWORD;
	replace_tag_in_file $kube_dir/mobius/mobiusserver/$MOBIUS_VALUES_FILE "<POSTGRESQL_HOST>" $POSTGRESQL_HOST;
	replace_tag_in_file $kube_dir/mobius/mobiusserver/$MOBIUS_VALUES_FILE "<POSTGRESQL_PORT>" $POSTGRESQL_PORT;
	replace_tag_in_file $kube_dir/mobius/mobiusserver/$MOBIUS_VALUES_FILE "<POSTGRESQL_DBNAME_MOBIUS>" $POSTGRESQL_DBNAME_MOBIUS;
	replace_tag_in_file $kube_dir/mobius/mobiusserver/$MOBIUS_VALUES_FILE "<NAMESPACE>" $NAMESPACE;
	replace_tag_in_file $kube_dir/mobius/mobiusserver/$MOBIUS_VALUES_FILE "<POSTGRESQL_DBNAME_EVENTANALYTICS>" $POSTGRESQL_DBNAME_EVENTANALYTICS;

	replace_tag_in_file $kube_dir/mobius/mobiusserver/$MOBIUS_VALUES_FILE "<ELASTICSEARCH_HOST>" $ELASTICSEARCH_HOST;
	replace_tag_in_file $kube_dir/mobius/mobiusserver/$MOBIUS_VALUES_FILE "<ELASTICSEARCH_PORT>" $ELASTICSEARCH_PORT;
	
	replace_tag_in_file $kube_dir/mobius/mobiusserver/$MOBIUS_VALUES_FILE "<KAFKA_BOOTSTRAP_URL>" $KAFKA_BOOTSTRAP_URL;

    if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
       info_message "Creating namespace $NAMESPACE..."
       kubectl create namespace "$NAMESPACE"
    fi

    info_message "Creating mobius storage";    
    kubectl apply -f $kube_dir/mobius/mobiusserver/mobius_storage.yaml --namespace $NAMESPACE;
	
	info_message "Deploy mobius"; 
    helm upgrade mobius -n $NAMESPACE $kube_dir/mobius/mobiusserver/helm/mobius.tgz  --create-namespace -f $kube_dir/mobius/mobiusserver/mobiusserver.yaml --install
}


wait_for_mobius_ready() {
    info_message "Waiting for mobius to be ready";
    COUNTER=0
	output=`kubectl get pods -n $NAMESPACE -o go-template --template '{{range .items}}{{if eq (.status.phase) ("Running")}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}'`
    until [[ "$output" == *mobius* ]]
    do
        info_progress "...";
		let COUNTER=COUNTER+5
		if [[ "$COUNTER" -gt 300 ]]; then
		  echo "FATAL: Failed to install mobius. Please check logs and configuration"
          exit 1    
		fi
        sleep 5;
		output=`kubectl get pods -n $NAMESPACE -o go-template --template '{{range .items}}{{if eq (.status.phase) ("Running")}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}'`
    done
}

remove_mobius(){
    info_message "Removing mobius"; 
    helm uninstall mobius -n $NAMESPACE 
	kubectl delete pvc mobius-diagnose-claim --namespace $NAMESPACE 
	kubectl delete pv mobius-diagnose --namespace $NAMESPACE 

}