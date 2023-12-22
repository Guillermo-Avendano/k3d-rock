#!/bin/bash
set -Eeuo pipefail

source ../env.sh
source ./env.sh
source ../cluster/common.sh

install_eventanalytics() {
		
	EVENTANALYTICS_VALUES_FILE=eventanalytics.yaml;
    cp $kube_dir/mobius/eventanalytics/templates/$EVENTANALYTICS_VALUES_FILE $kube_dir/mobius/eventanalytics/$EVENTANALYTICS_VALUES_FILE;

    #sed 's/\([^=]*\)=\(.*\)/s\/<\1>\/\2\/g/' $kube_dir/mobius/env.sh | xargs -I {} sed -i {} $kube_dir/mobius/eventanalytics/$EVENTANALYTICS_VALUES_FILE

	replace_tag_in_file $kube_dir/mobius/eventanalytics/$EVENTANALYTICS_VALUES_FILE "<KUBE_LOCALREGISTRY_HOST>" $KUBE_LOCALREGISTRY_HOST;
	replace_tag_in_file $kube_dir/mobius/eventanalytics/$EVENTANALYTICS_VALUES_FILE "<KUBE_LOCALREGISTRY_PORT>" $KUBE_LOCALREGISTRY_PORT;
	replace_tag_in_file $kube_dir/mobius/eventanalytics/$EVENTANALYTICS_VALUES_FILE "<IMAGE_NAME_EVENTANALYTICS>" $IMAGE_NAME_EVENTANALYTICS;
	replace_tag_in_file $kube_dir/mobius/eventanalytics/$EVENTANALYTICS_VALUES_FILE "<IMAGE_VERSION_EVENTANALYTICS>" $IMAGE_VERSION_EVENTANALYTICS;
	replace_tag_in_file $kube_dir/mobius/eventanalytics/$EVENTANALYTICS_VALUES_FILE "<POSTGRESQL_HOST>" $POSTGRESQL_HOST;
	replace_tag_in_file $kube_dir/mobius/eventanalytics/$EVENTANALYTICS_VALUES_FILE "<POSTGRESQL_PORT>" $POSTGRESQL_PORT;
	replace_tag_in_file $kube_dir/mobius/eventanalytics/$EVENTANALYTICS_VALUES_FILE "<POSTGRESQL_USERNAME>" $POSTGRESQL_USERNAME;
	replace_tag_in_file $kube_dir/mobius/eventanalytics/$EVENTANALYTICS_VALUES_FILE "<POSTGRESQL_PASSWORD>" $POSTGRESQL_PASSWORD;
	replace_tag_in_file $kube_dir/mobius/eventanalytics/$EVENTANALYTICS_VALUES_FILE "<POSTGRESQL_DBNAME_EVENTANALYTICS>" $POSTGRESQL_DBNAME_EVENTANALYTICS;
	replace_tag_in_file $kube_dir/mobius/eventanalytics/$EVENTANALYTICS_VALUES_FILE "<NAMESPACE>" $NAMESPACE;
	replace_tag_in_file $kube_dir/mobius/eventanalytics/$EVENTANALYTICS_VALUES_FILE "<KAFKA_BOOTSTRAP_URL>" $KAFKA_BOOTSTRAP_URL;
	
	
    if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
       info_message "Creating namespace $NAMESPACE..."
       kubectl create namespace "$NAMESPACE"
	   if [ "$KUBE_ISTIO_ENABLED_MOBIUS" == "true" ]; then
         kubectl label namespace $NAMESPACE istio-injection=enabled
       fi 
    fi
	
	info_message "Deploy eventanalytics"; 
    helm upgrade eventanalytics -n $NAMESPACE $kube_dir/mobius/eventanalytics/helm/eventanalytics-1.3.20.tgz --create-namespace -f $kube_dir/mobius/eventanalytics/$EVENTANALYTICS_VALUES_FILE --install	
}

get_eventanalytics_status() {
    kubectl get pods --namespace $NAMESPACE eventanalytics -o jsonpath="{.status.phase}" 2>/dev/null
}

wait_for_eventanalytics_ready() {
    info_message "Waiting for eventanalytics to be ready";
    COUNTER=0
	output=`kubectl get pods -n $NAMESPACE -o go-template --template '{{range .items}}{{if eq (.status.phase) ("Running")}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}'`
    until [[ "$output" == *eventanalytics* ]]
    do
        info_progress "...";
		let COUNTER=COUNTER+5
		if [[ "$COUNTER" -gt 300 ]]; then
		  echo "FATAL: Failed to install eventanalytics. Please check logs and configuration"
          exit 1    
		fi
        sleep 5;
		output=`kubectl get pods -n $NAMESPACE -o go-template --template '{{range .items}}{{if eq (.status.phase) ("Running")}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}'`
    done
}

remove_eventanalytics(){
    info_message "Removing eventanalytics"; 
	helm uninstall eventanalytics -n $NAMESPACE 
}

